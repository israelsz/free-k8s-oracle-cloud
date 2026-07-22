# Application catalog bootstrap

This directory contains one small catalog Argo CD Application. Its source is the
public `israelsz/free-k8s-oracle-cloud` repository on the `main` branch.

The catalog recursively scans `gitops/applications` but includes only files that
match `*/application.yaml`. It therefore creates every child Application while
ignoring their `values.yaml` and `manifest/` contents. Push access to the catalog
and application definitions is effectively cluster-administrator access and must
be protected accordingly.

This object is sometimes called a “root app” or “app of apps.” In this repository
we call it the application catalog because that describes its only job. It is
applied only after the first Argo CD installation exists.
