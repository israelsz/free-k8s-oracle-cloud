# Argo CD bootstrap release

Bootstrap logic lives here, but the actual Argo CD Application and Helm values
live together at `gitops/applications/argocd/`. The first installation renders
that same pinned chart and values before Argo CD exists.

Initial constraints:

- one non-HA control-plane deployment sized for the two-node cluster;
- server exposed only as `ClusterIP`;
- no public Argo CD route initially;
- chart and image versions pinned explicitly;
- Git repository URL supplied at bootstrap time, not hardcoded to a placeholder;
- no plaintext repository credential committed to Git.

After the first installation, `applications/argocd/application.yaml` owns Argo
CD. Bootstrap then limits itself to recovery checks and the catalog Application;
it does not become a second long-term owner of the Helm-rendered resources.
