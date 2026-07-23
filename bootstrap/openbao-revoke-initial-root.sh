#!/usr/bin/env bash

set -euo pipefail

namespace="openbao"
pod="openbao-0"

if ! command -v kubectl >/dev/null 2>&1; then
  printf 'Required command not found: kubectl\n' >&2
  exit 1
fi

if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
  printf 'Run this script from an interactive terminal.\n' >&2
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
  printf 'OpenBao is not Ready. Do not revoke the root token yet.\n' >&2
  exit 1
fi

printf '\nThis permanently revokes the initial root token.\n'
printf 'Continue only after a normal administrator login has been tested.\n'
read -r -p 'Type REVOKE to continue: ' confirmation
if [[ "${confirmation}" != "REVOKE" ]]; then
  printf 'Root-token revocation cancelled.\n'
  exit 0
fi

# OpenBao owns the hidden token prompt. It stores the token only in a unique
# temporary file inside the pod, validates the root policy, revokes the token,
# and removes the file on success, failure, or interruption.
kubectl --namespace "${namespace}" exec --stdin --tty "${pod}" -- sh -c '
  set -eu

  export BAO_ADDR="https://127.0.0.1:8200"
  export BAO_CACERT="/openbao/tls/ca.crt"
  export BAO_TOKEN_PATH="/tmp/openbao-root-revoke-token.$$"
  unset BAO_TOKEN VAULT_TOKEN

  cleanup() {
    rm -f "${BAO_TOKEN_PATH}"
  }
  trap cleanup EXIT HUP INT TERM

  printf "Enter the initial root token at the hidden OpenBao prompt.\n"
  bao login -no-print

  if ! bao read -field=policies auth/token/lookup-self | grep -qw root; then
    printf "Refusing to continue: the authenticated token is not a root token.\n" >&2
    exit 1
  fi

  bao token revoke -self
'

printf '\nThe initial root token is revoked. Keep the recovery keys offline.\n'
