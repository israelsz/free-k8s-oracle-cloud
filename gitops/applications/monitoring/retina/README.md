# Retina

OKE's VCN-native CNI gives pods directly routable VCN addresses through
`ipvlan`. On this cluster, kubelet's cAdvisor endpoint exposes network counters
only for node interfaces: its network samples have empty `namespace` and `pod`
labels. The ordinary Kubernetes pod, namespace, and workload networking
dashboards therefore cannot group those samples correctly.

Retina fills that gap without replacing OCI networking or Calico policy
enforcement. One eBPF agent runs on each worker and exports pod-aware traffic,
drop, DNS, TCP, and API-server latency metrics. VMAgent scrapes only the
`networkobservability_*` series and stores them in the existing VMSingle.

Remote context attaches both source and destination pod identities so the
bundled traffic dashboard is complete. That can create a series for each
observed pair, which is acceptable for this intentionally small cluster. High
aggregation, explicit CPU and memory limits, and the existing seven-day metric
retention keep it bounded. No load balancer, disk, OCI logging service, or
other billable cloud resource is created.

The agent must inspect host networking. Its init container is privileged and
the running agent receives the kernel capabilities required by its documented
`packetparser` plugin. For that reason it belongs in `node-observability`, not
the restricted `monitoring` namespace. A small non-privileged operator
maintains the pod metadata used to enrich those observations.
