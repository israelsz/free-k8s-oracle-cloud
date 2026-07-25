# VictoriaMetrics Kubernetes stack

The pinned upstream chart provides VMAgent, one VictoriaMetrics database, one
VictoriaLogs database, Grafana, kube-state-metrics, node exporter, VMAlert, and
Alertmanager. Managed OKE control-plane components that cannot be scraped from
worker pods are disabled to avoid false targets and alerts.

Metrics are kept for seven days. Logs are kept for three days and VictoriaLogs
also removes old partitions after its data directory passes 4 GiB. Both stores
use `local-boot`, so their PVC sizes describe the intended budget but are not
filesystem quotas. Application retention flags and node-filesystem alerts are
the actual safeguards.

Grafana installs the official VictoriaLogs data-source plugin and provisions
both data sources automatically. It serves verified HTTPS to the shared Envoy
Gateway and accepts Google Generic OAuth only when the returned, verified email
matches the value delivered from OpenBao. The local administrator is retained
only as a break-glass login.

Chart CRDs are part of this Application. Version upgrades must remain pinned
and include a review of rendered CRD changes before the chart version changes.
