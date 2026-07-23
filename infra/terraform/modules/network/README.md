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
list. OKE resources use role-specific NSGs. The public subnet's security list
does not open the origin; the load balancer's controller-owned frontend NSG
applies the Cloudflare-only source ranges from its Kubernetes Service.

The Pod NSG permits public HTTPS plus TCP/UDP DNS through the NAT gateway.
Kubernetes NetworkPolicy narrows those ports for each workload; for example,
only the cert-manager controller receives direct public DNS access for ACME
DNS-01 self-checks.

This module creates neither the OKE cluster nor a load balancer. The OKE module
attaches the API, worker, and pod NSGs. The OCI cloud controller later creates
the Envoy load balancer's frontend NSG and uses the worker NSG as its default
backend NSG. Allowed public source ranges stay with the Kubernetes Service that
owns the load balancer.
