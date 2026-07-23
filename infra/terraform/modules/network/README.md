# Network module

Owns one regional VCN with four role-specific subnets:

- private Kubernetes API endpoint;
- private managed workers;
- private VCN-native pods;
- public load balancer.

Private routes use one NAT gateway for controlled internet egress and one
service gateway for OCI regional services. The public load-balancer subnet uses
an internet gateway and never receives a service-gateway route, avoiding
asymmetric routing.

Every subnet uses an explicit security list instead of inheriting OCI's default
list. OKE resources use role-specific NSGs. The origin accepts TCP/443 only from
the current Cloudflare IPv4 ranges supplied by the production root.

The Pod NSG permits public HTTPS plus TCP/UDP DNS through the NAT gateway.
Kubernetes NetworkPolicy narrows those ports for each workload; for example,
only the cert-manager controller receives direct public DNS access for ACME
DNS-01 self-checks.

This module creates neither the OKE cluster nor a load balancer. The OKE module
attaches the API, worker, and pod NSGs. The Envoy Gateway Service later attaches
the load-balancer NSG through OCI load-balancer annotations.
