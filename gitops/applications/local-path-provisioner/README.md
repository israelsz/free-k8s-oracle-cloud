# Local boot-disk storage

The `local-boot` StorageClass dynamically creates PersistentVolumes under
`/var/lib/local-boot` on the worker selected for a pod. It uses space from that
worker's existing boot volume and does not create an OCI Block Volume.

`WaitForFirstConsumer` lets the scheduler choose a node before the volume is
created. The resulting volume is pinned to that node and cannot follow a pod to
the other worker. Applications that need availability must keep another copy on
the other node; CloudNativePG will do this for PostgreSQL.

The StorageClass is deliberately not the cluster default. Every workload must
choose `storageClassName: local-boot` explicitly. Its reclaim policy is `Retain`,
so deleting a claim does not immediately erase the data directory. Reusing or
removing retained data remains a manual recovery decision.
