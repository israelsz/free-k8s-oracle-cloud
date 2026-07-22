# Application folder template

Copy this directory to `gitops/applications/<application-name>` when adding a
component. Rename `application.yaml.example` to `application.yaml`, replace every
placeholder, and commit it. The catalog Application discovers it automatically
through the `*/application.yaml` include pattern.

Remove the Helm source and `values.yaml` for a manifest-only application. Remove
the manifest source when the chart needs no extra Kubernetes resources.
