# Argo CD application

Argo CD is installed from the upstream `argo-cd` Helm chart and then manages its
own rendered resources.

The chart is pinned to `10.1.4`, which packages Argo CD `v3.4.5`. The small
cluster profile runs one controller, repo server, API server, and Redis instance.
Dex, notifications, ApplicationSet replicas, and every public service are off.

The first bootstrap renders the pinned chart with this directory's `values.yaml`
because Argo CD does not exist yet. Bootstrap then creates the App of Apps,
which discovers `application.yaml`. From that point onward Argo CD
reconciles its own chart and the bootstrap installer stops upgrading it.

Self-management requires `ServerSideApply=true`. A bad Argo CD chart/value
change can damage the deployment controller itself, so upgrades must be pinned,
reviewed, and tested, and automated pruning stays disabled initially for this
one Application.
