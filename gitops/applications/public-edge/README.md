# Public edge

This manifest-only application owns the shared Envoy data plane, its
`GatewayClass`, the public `Gateway`, and the certificates used at the origin.

OKE sees Envoy's `LoadBalancer` Service and creates one OCI Flexible Load
Balancer pinned to 10 Mbps. Its controller-owned frontend NSG accepts port 443
only from Cloudflare's published IPv4 ranges. The Terraform-managed worker NSG
is the default backend NSG.

The Gateway reserves HTTPS listeners for Argo CD and OpenBao, but this
application intentionally creates no `HTTPRoute`. Neither admin service becomes
reachable until its native Google OIDC configuration and exact-account
authorization are ready.

The two Envoy replicas are spread across the two workers. A
`PodDisruptionBudget` keeps at least one proxy available during voluntary
maintenance.

