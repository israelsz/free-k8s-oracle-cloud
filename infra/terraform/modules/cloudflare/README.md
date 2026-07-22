# Cloudflare module

Owns static settings for the configured public DNS zone and the `www` redirect.
It does not manage records delegated to ExternalDNS.

The Cloudflare API token is supplied through the provider's environment variable
and must be limited to the required permissions for this zone.
