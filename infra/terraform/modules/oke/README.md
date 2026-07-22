# OKE module

Owns one private OKE Basic cluster and one two-node Ampere A1 managed node pool.
It uses OCI VCN-native pod networking and attaches the API, worker, and pod NSGs
created by the network module.

The currently reviewed versions and sizes are deliberately fixed:

- Kubernetes `v1.35.2` on the control plane and workers;
- `Oracle-Linux-8.10-aarch64-2026.06.15-0-OKE-1.35.2-1505`;
- two `VM.Standard.A1.Flex` nodes at 2 OCPU and 12 GB each;
- one 50 GB boot volume per node;
- 31 VCN-native pod addresses per node;
- one regional worker subnet in Santiago AD-1, with all fault domains offered
  so OCI can spread the two nodes when capacity allows.

Plan-time checks ask the live regional OKE API whether the pinned Kubernetes
version, image, and A1 shape are still offered. A missing free shape or image is
an error; the module never substitutes another shape.

Automatic node cycling is disabled because a surge node would temporarily
exceed the 4-OCPU/24-GB Always Free allocation. Kubernetes upgrades therefore
need a reviewed, one-node-at-a-time runbook.

This module creates no Kubernetes namespaces, Helm releases, or workloads.
