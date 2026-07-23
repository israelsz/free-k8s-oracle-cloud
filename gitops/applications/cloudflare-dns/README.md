# Cloudflare DNS integration

This manifest-only application connects cert-manager to a single Cloudflare
zone after cert-manager, OpenBao, trust-manager, and External Secrets are
running. Keeping it separate prevents an External Secrets dependency from
blocking cert-manager during a fresh cluster bootstrap.

It creates:

- a dedicated OpenBao reader service account and namespaced `SecretStore`;
- an `ExternalSecret` that materializes only cert-manager's Cloudflare token;
- Let's Encrypt staging and production `ClusterIssuer` resources.

No API token, personal domain, zone ID, account identifier, or email address is
stored in Git. The Cloudflare token itself limits access to one specific zone.
