# Argo CD application

Argo CD is installed from the upstream `argo-cd` Helm chart and then manages its
own rendered resources.

The chart is pinned to `10.1.4`, which packages Argo CD `v3.4.5`. The small
cluster profile runs one controller, repo server, API server, and Redis instance.
Dex, notifications, ApplicationSet replicas, and every public service are off.

Native OIDC is configured without committing either Google client value. An
`ExternalSecret` reads one exact OpenBao KV document and creates a Secret
labelled for Argo CD. The ConfigMap refers to the two Secret keys by name.
Authenticated identities receive no default permissions; the reviewed RBAC
mapping grants the approved operator administrator access.

The two clients must be configured in OpenBao before these resources are
applied. The built-in administrator remains enabled until the native login has
been tested, so a configuration mistake does not remove the break-glass login.

cert-manager issues the internal Argo CD server certificate from the platform's
private CA and renews the conventional `argocd-server-tls` Secret. Envoy's
`BackendTLSPolicy` verifies both that CA and the internal Service hostname.
The public Gateway certificate remains separate: it authenticates the public
hostname to browsers, while this certificate authenticates Argo CD to Envoy.

The first bootstrap renders the pinned chart with this directory's `values.yaml`
because Argo CD does not exist yet. Bootstrap then creates the App of Apps,
which discovers `application.yaml`. From that point onward Argo CD
reconciles its own chart and the bootstrap installer stops upgrading it.

Self-management requires `ServerSideApply=true`. A bad Argo CD chart/value
change can damage the deployment controller itself, so upgrades must be pinned,
reviewed, and tested, and automated pruning stays disabled initially for this
one Application.
