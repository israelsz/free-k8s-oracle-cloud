#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
namespace="argocd"
chart_version="10.1.4"
timeout="${ARGOCD_BOOTSTRAP_TIMEOUT:-10m}"

values_file="${repo_root}/gitops/applications/argocd/values.yaml"
app_bootstrap="${repo_root}/gitops/bootstrap/app-bootstrap.yaml"

for command_name in helm kubectl; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "${command_name}" >&2
    exit 1
  fi
done

for required_file in "${values_file}" "${app_bootstrap}"; do
  if [[ ! -r "${required_file}" ]]; then
    printf 'Required bootstrap file is not readable: %s\n' "${required_file}" >&2
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

if kubectl get application argocd --namespace "${namespace}" >/dev/null 2>&1; then
  printf 'Argo CD already manages itself; skipping the initial chart installation.\n'
else
  printf 'Installing Argo CD chart %s...\n' "${chart_version}"

  kubectl create namespace "${namespace}" \
    --dry-run=client \
    --output=yaml |
    kubectl apply \
      --server-side \
      --field-manager=argocd-bootstrap \
      --filename=- >/dev/null

  helm template argocd argo-cd \
    --repo https://argoproj.github.io/argo-helm \
    --version "${chart_version}" \
    --namespace "${namespace}" \
    --include-crds \
    --skip-tests \
    --values "${values_file}" |
    kubectl apply \
      --server-side \
      --force-conflicts \
      --field-manager=argocd-bootstrap \
      --filename=- >/dev/null
fi

kubectl wait \
  --for=condition=Established \
  customresourcedefinition/applications.argoproj.io \
  --timeout=2m >/dev/null

for workload in \
  statefulset/argocd-application-controller \
  deployment/argocd-repo-server \
  deployment/argocd-server \
  deployment/argocd-redis; do
  kubectl rollout status \
    --namespace "${namespace}" \
    "${workload}" \
    --timeout="${timeout}"
done

printf 'Applying the App of Apps...\n'
kubectl apply \
  --server-side \
  --force-conflicts \
  --field-manager=argocd-bootstrap \
  --filename="${app_bootstrap}" >/dev/null

kubectl wait \
  --namespace "${namespace}" \
  --for=jsonpath='{.status.sync.status}'=Synced \
  application/app-bootstrap \
  --timeout="${timeout}"

kubectl wait \
  --namespace "${namespace}" \
  --for=create \
  application/argocd \
  --timeout="${timeout}" >/dev/null

kubectl wait \
  --namespace "${namespace}" \
  --for=jsonpath='{.status.sync.status}'=Synced \
  --for=jsonpath='{.status.health.status}'=Healthy \
  application/argocd \
  --timeout="${timeout}"

printf '\nArgo CD is installed and managing itself.\n'
