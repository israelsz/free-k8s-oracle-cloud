# Additional manifests

Place Kubernetes resources owned by this application here. Add a
`kustomization.yaml` when the folder contains resources so Argo CD renders it
explicitly.

Do not put resources from another application here merely to satisfy ordering;
use Argo CD sync waves on the respective `application.yaml` files instead.
