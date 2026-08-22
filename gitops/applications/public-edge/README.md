# Public edge

This app owns the public Envoy proxy, its Gateway, and the certificates used at
the OCI load balancer.

OKE sees Envoy's `LoadBalancer` Service and creates one OCI Flexible Load
Balancer at 10 Mbps. Every public app shares it, so a new hostname does not add
another paid or billable load balancer.

The Gateway has one HTTPS listener for each hostname. The app that serves that
hostname owns its own `HTTPRoute`. ExternalDNS creates a proxied Cloudflare
record only when that route has the public opt-in annotation.

Cloudflare connects to Envoy with HTTPS. Set both Cloudflare zones to **Full
(strict)** mode so Cloudflare checks the Let's Encrypt certificate at the
origin.

The admin apps start a second TLS connection from Envoy to their internal
Services. The LabRats landing page and Israheck site serve static files over
HTTP inside the cluster. Their NetworkPolicies accept traffic only from the
public Envoy pods, and the site pods have no allowed outbound traffic.

Envoy runs two replicas across the two workers. Its disruption budget keeps one
proxy running during planned node work.
