#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
infra_dir="${repo_root}/infra/terraform"
namespace="openbao"
secret_name="openbao-oci-kms"
terraform_bin="${TERRAFORM:-terraform}"

for command_name in "${terraform_bin}" jq kubectl; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "${command_name}" >&2
    exit 1
  fi
done

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

# Terraform state contains identifiers and endpoints, not KMS key material. Keep
# the JSON in memory and never echo it or enable shell tracing in this script.
data_protection_json="$(
  "${terraform_bin}" -chdir="${infra_dir}" output -json data_protection
)"

if ! printf '%s\n' "${data_protection_json}" | jq --exit-status '
  (.openbao_kms.key_id | type == "string" and startswith("ocid1.key.")) and
  (.openbao_kms.crypto_endpoint | type == "string" and startswith("https://")) and
  (.openbao_kms.management_endpoint | type == "string" and startswith("https://"))
' >/dev/null; then
  printf 'Terraform output data_protection.openbao_kms is missing or invalid.\n' >&2
  exit 1
fi

kubectl create namespace "${namespace}" \
  --dry-run=client \
  --output=yaml |
  kubectl apply \
    --server-side \
    --field-manager=openbao-bootstrap \
    --filename=- >/dev/null

printf '%s\n' "${data_protection_json}" |
  jq --exit-status --compact-output '
    {
      apiVersion: "v1",
      kind: "Secret",
      metadata: {
        name: "openbao-oci-kms",
        namespace: "openbao",
        labels: {
          "app.kubernetes.io/name": "openbao",
          "app.kubernetes.io/managed-by": "openbao-bootstrap"
        }
      },
      type: "Opaque",
      stringData: {
        "VAULT_OCIKMS_SEAL_KEY_ID": .openbao_kms.key_id,
        "VAULT_OCIKMS_CRYPTO_ENDPOINT": .openbao_kms.crypto_endpoint,
        "VAULT_OCIKMS_MANAGEMENT_ENDPOINT": .openbao_kms.management_endpoint
      }
    }
  ' |
  kubectl apply \
    --server-side \
    --force-conflicts \
    --field-manager=openbao-bootstrap \
    --filename=- >/dev/null

printf 'OpenBao KMS configuration installed in namespace %s\n' "${namespace}"
printf 'Argo CD can now create the OpenBao StatefulSet.\n'
