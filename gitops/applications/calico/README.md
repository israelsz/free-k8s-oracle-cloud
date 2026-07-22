# Calico policy engine

Calico enforces Kubernetes and Calico network policies. It does not replace the
OCI VCN-native CNI: OCI continues assigning pod IPs and routing pod traffic.

OKE requires several changes to Calico's policy-only manifest so Calico does
not install another CNI or modify OCI's CNI configuration. The Kustomization in
`manifest/` applies those Oracle-documented changes to Calico `v3.31.5`, the
version Oracle tests with Kubernetes 1.35. The upstream source is pinned to its
immutable Git commit.

Typha is removed because the two Calico node agents talk directly to the
Kubernetes API; it is useful for reducing API load in much larger clusters.

Installing this application does not block any traffic by itself. Policies are
added separately and tested namespace by namespace.
