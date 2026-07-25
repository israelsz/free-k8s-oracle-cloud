# Monitoring

This parent Application groups three independently reconciled components:

- `victoria-metrics-k8s-stack` provides metrics collection and storage,
  VictoriaLogs storage, Grafana, dashboards, and alert evaluation;
- `victoria-logs-collector` reads Kubernetes container logs from every worker
  and sends them to VictoriaLogs;
- `retina` adds pod-aware traffic, drop, DNS, and TCP metrics that OKE's
  VCN-native kubelet endpoint does not provide.

The split is a security boundary. Most monitoring workloads run in the
restricted `monitoring` namespace. Node exporter, the log collector, and
Retina require host access, so they run in the dedicated `node-observability`
namespace. Node exporter and the log collector remain non-privileged. Retina
is the explicit exception: its init container and eBPF plugins need kernel
access to observe pod traffic.

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
