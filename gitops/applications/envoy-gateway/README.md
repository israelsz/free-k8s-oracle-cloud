# Envoy Gateway

This application installs the Envoy Gateway controller from its pinned upstream
OCI Helm chart. Gateway API and Envoy extension CRDs are owned separately by the
`gateway-api` application.

The controller stays behind a `ClusterIP`. The `public-edge` application creates
the managed Envoy data plane and the one OCI load balancer.

Network policies allow only:

- the private Kubernetes API to call the topology webhook;
- the controller and Envoy proxies to exchange xDS configuration;
- controllers to reach the private Kubernetes API and cluster DNS;
- the OCI load-balancer subnet to reach Envoy's HTTPS listener.

Backend access is added per published application instead of giving Envoy
blanket access to every pod.

