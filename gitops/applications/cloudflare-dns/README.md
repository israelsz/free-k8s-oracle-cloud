# Cloudflare DNS for certificates

This app gives cert-manager the Cloudflare token it needs for DNS-01 checks.
Those checks prove that we control a domain before Let's Encrypt issues a
certificate.

The token can change DNS records only in authorized domains. It has
`Zone Read` and `DNS Edit` for those two zones. OpenBao holds the token; Git
contains only the path used to read it.

This app creates:

- a service account and a namespaced OpenBao `SecretStore`;
- an `ExternalSecret` for the cert-manager token;
- Let's Encrypt staging and production issuers.

The app stays separate from the cert-manager chart. This lets cert-manager start
before OpenBao and External Secrets during a clean cluster build.
