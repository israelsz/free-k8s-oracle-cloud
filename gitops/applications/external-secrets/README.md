# External Secrets Operator

This application installs External Secrets Operator 2.4.1 and uses its supported
Vault-compatible provider to read OpenBao KV v2. Only namespace-scoped
`SecretStore` and `ExternalSecret` resources are enabled; cluster-wide stores,
recursive cluster distribution, write-back, generic targets, and token caching
are disabled.

The `external-secrets` namespace is the only client namespace allowed through
OpenBao's NetworkPolicy. Each workload still authenticates with a distinct
Kubernetes service account and OpenBao role, so namespace network access does
not grant secret access.

Applications should keep their namespaced `SecretStore` and `ExternalSecret`
resources beside the rest of their manifests. OpenBao policies and Kubernetes
auth roles are created separately and grant each workload read access only to
its own path.

The end-to-end access check is intentionally not stored in Git. It can create a
temporary namespace, service account, OpenBao path, policy, and role in the live
cluster, verify the generated Kubernetes Secret, and then delete all test state.

The store temporarily uses HTTP inside the restricted cluster network. Do not
put Cloudflare or other real credentials behind it until internal TLS and the CA
bundle are configured.
