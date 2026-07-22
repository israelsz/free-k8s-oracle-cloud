# App of Apps bootstrap

This directory contains the `app-bootstrap` Argo CD Application. Its source is
the public `israelsz/free-k8s-oracle-cloud` repository on the `main` branch.

This is the App of Apps: it recursively scans `gitops/applications` but includes
only files that match `*/application.yaml`. It creates every child Application
while ignoring their `values.yaml` and `manifest/` contents.

Push access to this file and the application definitions is effectively
cluster-administrator access and must be protected accordingly. Bootstrap
applies this object only after the first Argo CD installation exists.
