#!/usr/bin/env bash

set -euo pipefail

namespace="openbao"
pod="openbao-0"
admin_policy="platform-admin"

if ! command -v kubectl >/dev/null 2>&1; then
  printf 'Required command not found: kubectl\n' >&2
  exit 1
fi

current_context="$(kubectl config current-context 2>/dev/null || true)"
if [[ -z "${current_context}" ]]; then
  printf 'No Kubernetes context is active.\n' >&2
  exit 1
fi

printf 'Using Kubernetes context: %s\n' "${current_context}"
if ! kubectl get --raw=/readyz >/dev/null; then
  printf 'The Kubernetes API is unavailable. Is the OKE Bastion tunnel running?\n' >&2
  exit 1
fi

if ! kubectl --namespace "${namespace}" wait \
  --for=condition=Ready "pod/${pod}" \
  --timeout=30s >/dev/null; then
  printf 'OpenBao is not Ready. Check its pod before configuring it.\n' >&2
  exit 1
fi

printf '\nThis configures:\n'
printf '  - the %s human administrator policy and login\n' "${admin_policy}"
printf "  - Kubernetes authentication using OpenBao's rotating pod token\n"
printf '  - the versioned secret/ KV store\n'
printf '\nNothing entered below is written to a local file or Kubernetes Secret.\n'
printf 'Audit logging is configured declaratively in the OpenBao Helm values.\n\n'

read -r -p 'Admin username [admin]: ' admin_username
admin_username="${admin_username:-admin}"

# OpenBao userpass names accept alphanumerics plus underscore, dash, and dot;
# this stricter shape also prevents the name from being interpreted as a path.
if [[ ! "${admin_username}" =~ ^[[:alnum:]_][[:alnum:]_.-]*[[:alnum:]_]$ ]] &&
  [[ ! "${admin_username}" =~ ^[[:alnum:]_]$ ]]; then
  printf 'Invalid admin username. Use letters, digits, underscore, dash, or dot.\n' >&2
  exit 1
fi

read -r -s -p 'Initial root token: ' root_token
printf '\n'
if [[ -z "${root_token}" ]]; then
  printf 'The initial root token cannot be empty.\n' >&2
  exit 1
fi

read -r -s -p 'New admin password (16+ characters): ' admin_password
printf '\n'
read -r -s -p 'Confirm admin password: ' admin_password_confirm
printf '\n'

if (( ${#admin_password} < 16 )); then
  printf 'The admin password must contain at least 16 characters.\n' >&2
  exit 1
fi
if [[ "${admin_password}" != "${admin_password_confirm}" ]]; then
  printf 'The admin passwords do not match.\n' >&2
  exit 1
fi

# The two secrets travel only over kubectl stdin. They are not command-line
# arguments, environment variables on the local machine, or shell-history text.
remote_script="$(cat <<'REMOTE_SCRIPT'
set -eu

admin_username="$1"
admin_policy="$2"
export BAO_ADDR="https://127.0.0.1:8200"
export BAO_CACERT="/openbao/tls/ca.crt"

IFS= read -r BAO_TOKEN
IFS= read -r admin_password
export BAO_TOKEN

cleanup() {
  unset BAO_TOKEN admin_password admin_token
}
trap cleanup EXIT HUP INT TERM

if ! bao status >/dev/null 2>&1; then
  printf 'OpenBao is sealed or unavailable.\n' >&2
  exit 1
fi
if ! bao token lookup >/dev/null 2>&1; then
  printf 'The supplied initial root token was rejected.\n' >&2
  exit 1
fi

# Audit devices are deliberately not created through the API. Refuse to do the
# security bootstrap until the declarative stdout device is active.
if ! bao audit list -format=json | grep -q '"stdout/"'; then
  printf 'The declarative stdout audit device is not active.\n' >&2
  printf 'Push the GitOps change, let Argo CD sync, and restart openbao-0 first.\n' >&2
  exit 1
fi

# This is the daily operator policy. It is intentionally powerful, but unlike
# the immortal root token its login tokens expire and can be revoked.
printf '%s\n' \
  'path "*" {' \
  '  capabilities = ["create", "read", "update", "patch", "delete", "list", "scan", "sudo"]' \
  '}' |
  bao policy write "${admin_policy}" - >/dev/null

if ! bao auth list -format=json | grep -q '"userpass/"'; then
  bao auth enable userpass >/dev/null
fi

# Reading the password from stdin keeps it out of the container process list.
printf '%s' "${admin_password}" |
  bao write "auth/userpass/users/${admin_username}" \
    password=- \
    token_policies="${admin_policy}" \
    token_ttl=1h \
    token_max_ttl=8h >/dev/null

if ! bao auth list -format=json | grep -q '"kubernetes/"'; then
  bao auth enable kubernetes >/dev/null
fi

# Because OpenBao itself runs in Kubernetes, it can reread its own rotating
# service-account token and CA. No long-lived reviewer token is stored here.
bao write auth/kubernetes/config \
  kubernetes_host="https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}" \
  disable_iss_validation=true >/dev/null

if ! bao secrets list -format=json | grep -q '"secret/"'; then
  bao secrets enable -path=secret kv-v2 >/dev/null
fi

# Prove the new login works, then immediately revoke this one test token.
admin_token="$(
  BAO_TOKEN='' printf '%s' "${admin_password}" |
    BAO_TOKEN='' bao write -field=token \
      "auth/userpass/login/${admin_username}" password=-
)"
BAO_TOKEN="${admin_token}" bao token lookup >/dev/null
bao token revoke "${admin_token}" >/dev/null

printf 'OpenBao post-initialization configuration completed.\n'
printf 'Verified the %s user and revoked its one-time test token.\n' "${admin_username}"
REMOTE_SCRIPT
)"

if ! printf '%s\n%s\n' "${root_token}" "${admin_password}" |
  kubectl --namespace "${namespace}" exec --stdin "${pod}" -- \
    sh -c "${remote_script}" -- "${admin_username}" "${admin_policy}"; then
  unset root_token admin_password admin_password_confirm remote_script
  printf 'OpenBao configuration failed; the initial root token was not revoked.\n' >&2
  exit 1
fi

unset root_token admin_password admin_password_confirm remote_script

printf '\nKeep the initial root token for the moment.\n'
printf 'Revoke it only after a separate admin login has been tested.\n'
