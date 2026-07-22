# Local modules

The production root composes these modules directly; modules do not call each
other. This keeps the dependency graph flat and visible.

| Module | Responsibility |
| --- | --- |
| `network` | VCN, private/public subnets, gateways, routes, and network security |
| `identity` | Human operator group and least-privilege Bastion/OKE access policy |
| `oke` | OKE Basic cluster and two private Ampere A1 workers |
| `access` | OCI Bastion and private API access prerequisites |
| `data-protection` | OpenBao KMS key, worker dynamic group, and workload backup bucket |
| `cost-guardrails` | 1-unit budget with actual and forecast email alerts |
| `cloudflare` | Static zone settings and redirects, excluding ExternalDNS-owned records |

Each implemented module uses `main.tf`, `variables.tf`, and `outputs.tf`, with
validation on any value that can affect cost. Modules may add a small `data.tf`
when live regional compatibility must be checked without owning a resource.
