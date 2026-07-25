# VictoriaLogs Collector

The official collector chart runs one `vlagent` pod per worker. It tails
Kubernetes container logs under the node's `/var/log`, enriches them with pod
metadata, and sends them to the private VictoriaLogs Service in `monitoring`.
Fluent Bit or Vector must not run alongside it, because a second collector
would ingest duplicate logs.

Each worker keeps at most 256 MiB of unsent data under
`/var/lib/vl-collector`. If VictoriaLogs remains unavailable after that buffer
fills, the oldest unsent records are discarded instead of filling the boot
disk. The collector stores pod labels but not annotations or node metadata, and
drops common structured credential fields before transmission.

The pod must read host log paths and maintain a node-local checkpoint. Its
namespace permits those host mounts, while the container itself uses a
read-only root filesystem, drops Linux capabilities, and is not privileged.
