# ExternalDNS

This application installs ExternalDNS 0.21.0 from the official chart and lets
it manage only records explicitly opted in with:

```yaml
external-dns.alpha.kubernetes.io/expose: public
```

The Cloudflare token is delivered from OpenBao through a namespaced
`SecretStore`. It is not stored in Git. The token itself is restricted to one
Cloudflare zone, which is the provider-side boundary; the personal domain and
zone ID do not need to appear in this repository.

The ExternalDNS token is separate from cert-manager's token. It has the same
minimal `Zone - Zone - Read` and `Zone - DNS - Edit` permissions for one
specific zone, so either token can be revoked or rotated without sharing a
credential between controllers.

`policy=sync` removes records that disappear from desired Kubernetes state, but
the TXT registry permits deletion only for records carrying this cluster's
`oracle-free-oke-prod` owner ID. The `_edns-%{record_type}.` prefix prevents
ownership TXT records from colliding with application records and must not be
changed after the first record is created.

The initial source is `service`, limited to the otherwise empty `external-dns`
namespace. The Service source also starts a Node watcher when it calculates
targets, so a small ClusterRole grants only `get`, `list`, and `watch` for
Nodes. All Service reads remain limited to the `external-dns` namespace.

After Envoy Gateway installs the Gateway API CRDs, the source changes to
`gateway-httproute` with reviewed Gateway API read permissions. Public
`HTTPRoute` objects will carry both the opt-in annotation and Cloudflare's
per-route proxy annotation.
