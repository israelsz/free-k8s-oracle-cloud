# Gateway API

This application installs the standard Kubernetes Gateway API CRDs and the
Envoy Gateway extension CRDs from the version-pinned upstream CRD chart.

The CRDs are separate from the controller so Argo CD can update their schemas
during future upgrades. Experimental Gateway API resources are deliberately
disabled.

