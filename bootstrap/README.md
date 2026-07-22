# Cluster bootstrap

Bootstrap is the narrow procedural bridge between Terraform and Argo CD.

Idempotent sequence:

1. Read Terraform outputs for the cluster, Bastion, and region.
2. Generate a temporary kubeconfig outside the repository.
3. Open a time-limited OCI Bastion tunnel to the private OKE API.
4. For the first installation only, render the pinned `argo-cd` Helm chart with
   `gitops/applications/argocd/values.yaml` and apply the rendered resources.
5. Apply the `app-bootstrap` App of Apps from `gitops/bootstrap`; it discovers
   only `gitops/applications/*/application.yaml` files.
6. Let `applications/argocd/application.yaml` adopt ongoing management of Argo
   CD using the same chart and values file, then wait for every application to
   become Synced and Healthy.
7. Close the tunnel and delete generated access files.

Bootstrap must be safe to rerun after partial failure. Once the self-managed
Argo CD Application is healthy, reruns must not perform an independent Helm
upgrade over it. Bootstrap must never print OpenBao recovery material,
Cloudflare tokens, OCI customer secret keys, or registry credentials.

The intended first-install mechanism is `helm template` followed by Kubernetes
server-side apply, rather than creating a long-lived Helm release that could
later compete with Argo CD for ownership. The chart version used for this first
installation matches the version in the Argo CD Application.

Run `bootstrap/gitops-bootstrap.sh` while the Bastion tunnel is open. It prints
the active Kubernetes context, checks that its API is reachable, installs Argo
CD if the self-managed Application does not exist yet, and applies the App of
Apps. The initial server remains a `ClusterIP`.

OpenBao initialization remains an explicit interactive checkpoint. OCI KMS can
auto-unseal an initialized OpenBao instance, but cannot initialize it.

Before pushing/enabling the OpenBao Application, run
`bootstrap/openbao-prerequisites.sh` with the OKE tunnel open. It copies the
non-secret KMS identifiers from Terraform state into a Kubernetes Secret without
printing them. It does not initialize OpenBao or handle recovery material.
