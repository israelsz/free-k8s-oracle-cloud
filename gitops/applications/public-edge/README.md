# Public edge

This manifest-only application owns the shared Envoy data plane, its
`GatewayClass`, the public `Gateway`, and the certificates used at the origin.

OKE sees Envoy's `LoadBalancer` Service and creates one OCI Flexible Load
Balancer pinned to 10 Mbps. Its controller-owned frontend NSG accepts port 443
only from Cloudflare's published IPv4 ranges. The Terraform-managed worker NSG
is the default backend NSG.

The Gateway has separate HTTPS listeners and routes for Argo CD and OpenBao.
Both applications authorize users through their own native OIDC implementation.
ExternalDNS creates proxied records only because these two routes carry the
repository's explicit public opt-in annotation.

TLS terminates at Envoy using public certificates, then Envoy opens new
CA-verified TLS connections to both internal Services. The application
certificates and `BackendTLSPolicy` resources prevent an unverified or plaintext
connection inside the cluster.

The Cloudflare zone must use **Full (strict)** SSL/TLS mode. Flexible mode would
try plaintext HTTP to an origin that intentionally exposes HTTPS only.

The two Envoy replicas are spread across the two workers. A
`PodDisruptionBudget` keeps at least one proxy available during voluntary
maintenance.
