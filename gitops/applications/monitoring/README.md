# Monitoring

This parent Application groups two independently reconciled components:

- `victoria-metrics-k8s-stack` provides metrics collection and storage,
  VictoriaLogs storage, Grafana, dashboards, and alert evaluation;
- `victoria-logs-collector` reads Kubernetes container logs from every worker
  and sends them to VictoriaLogs.

The split is a security boundary. Most monitoring workloads run in the
restricted `monitoring` namespace. Node exporter and the log collector require
read-only host mounts, so they run in the dedicated `node-observability`
namespace. That namespace permits host access, but the containers still drop
capabilities and do not run as privileged containers.

VictoriaMetrics and VictoriaLogs each use one `4Gi` claim from the explicit
`local-boot` StorageClass. These claims are directories on the existing worker
boot volumes, not new OCI Block Volumes. The two stores are scheduled on
different workers. Their history is useful but expendable: losing a worker can
lose the observability data pinned to it.

Grafana is stateless. Its dashboards and data sources come from Git, while its
Google OAuth client, exact allowed identity, and break-glass administrator
credentials come from two OpenBao KV documents through External Secrets. The
Kubernetes identity is scoped to Grafana's application prefix, so adding
another Grafana secret does not require another OpenBao policy or auth role.
Only Grafana is publicly routed; the metrics and logs databases remain
ClusterIP-only.
