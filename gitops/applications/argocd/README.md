# Argo CD application

Argo CD is installed from the upstream `argo-cd` Helm chart and then manages its
own rendered resources.

The first bootstrap renders the pinned chart with this directory's `values.yaml`
because Argo CD does not exist yet. Bootstrap then creates the application
catalog, which discovers `application.yaml`. From that point onward Argo CD
reconciles its own chart and the bootstrap installer stops upgrading it.

Self-management requires `ServerSideApply=true`. A bad Argo CD chart/value
change can damage the deployment controller itself, so upgrades must be pinned,
reviewed, and tested, and automated pruning stays disabled initially for this
one Application.
