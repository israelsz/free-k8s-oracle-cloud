# GitOps desired state

Argo CD reconciles this tree into the production OKE cluster. The only Argo CD
object applied directly by the bootstrap script is the App of Apps under
`bootstrap/`.

## Layout

- `bootstrap/`: App of Apps that discovers child Applications.
- `applications/<name>/`: one self-contained Argo CD application with its
  `application.yaml`, Helm `values.yaml`, and optional `manifest/` directory.

There is no separate platform-versus-workload source tree. OpenBao, cert-manager,
CloudNativePG, Grafana, and the portfolio all use the same per-application
layout. This keeps everything required to understand or change one deployment
next to its Argo CD Application definition.

Use maintained upstream Helm charts for deployable components, including Argo
CD itself. Component-specific Kubernetes objects that are not Helm releases—such
as a PostgreSQL `Cluster`, `HTTPRoute`, or `NetworkPolicy`—stay beside the chart
in that application's optional `manifest/` directory.

## Reconciliation order

| Wave | Content |
| ---: | --- |
| -40 | Namespaces, quotas, RBAC, storage, and admission foundations |
| -30 | Networking and policy controllers |
| -25 | Certificate issuance and trust distribution controllers |
| -20 | OpenBao |
| -15 | Secret-delivery controllers |
| -10 | Database, DNS, and observability operators |
| 0 | Stateful instances, issuers, gateways, and monitoring configuration |
| 10 | Portfolio and additional workloads |

Every child Application enables automated sync, self-healing, and retry.
`allowEmpty` remains false. Normal applications enable last-step pruning; the
self-managed Argo CD Application starts with pruning disabled. PVCs, namespaces
with durable state, OpenBao, and CloudNativePG clusters require explicit prune
confirmation.

## Rules

- Pin chart and image versions; never track `latest`.
- Every selected image must support `linux/arm64`.
- Put no secret value in Git, including example values that resemble a real key.
- Give every workload resource requests, limits, probes, and an
  `ephemeral-storage` budget.
- Application database hosts use the CloudNativePG `*-rw` Service.
- Public HTTP routes must use names under the configured base domain.
- Do not add an OCI Block Volume PVC except the reviewed OpenBao claim.
- Avoid manual `kubectl apply`; emergency changes must be brought back to Git.
