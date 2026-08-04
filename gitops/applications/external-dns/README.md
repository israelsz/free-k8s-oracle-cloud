# ExternalDNS

ExternalDNS reads approved `HTTPRoute` objects and keeps their Cloudflare DNS
records in sync. A route must include this annotation before ExternalDNS will
touch it:

```yaml
external-dns.alpha.kubernetes.io/expose: public
```

It can manage records only under authorized domains. The Helm
values list both zones, and the Cloudflare token has the same limit.

OpenBao holds the token and External Secrets places it in the namespace. The
token has only these Cloudflare permissions:

- `Zone → Zone → Read`
- `Zone → DNS → Edit`

cert-manager uses a different token. If one controller has a problem, we can
replace its token without stopping the other one.

`policy=sync` removes a DNS record when its approved route leaves Git. The TXT
registry lets this cluster remove only records with the
`oracle-free-oke-prod` owner ID. Do not change the TXT owner ID or prefix after
the first record exists.

The controller watches Gateways, HTTPRoutes, and Namespaces. It gets the public
IP from the Gateway status, then creates proxied Cloudflare records for routes
that use the opt-in annotation.
