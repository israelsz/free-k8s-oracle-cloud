# trust-manager

trust-manager 0.24.0 distributes public trust bundles to selected namespaces.
It does not issue certificates and has no permission to copy Secret objects
between namespaces.

The OpenBao application defines one `Bundle` sourced from the root certificate
in the `cert-manager` namespace. A namespace receives the public CA ConfigMap
only when it carries the label `openbao-trust=enabled`. The CA private key is
never copied.
