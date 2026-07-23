# cert-manager

This application installs cert-manager 1.21.0 from its official OCI chart.
cert-manager owns certificate issuance and renewal, including the private
certificate used by OpenBao and later public certificates requested through
Cloudflare DNS validation.

The CRDs are retained if the Helm release is removed. The three controllers run
as single replicas with small resource limits and no PDBs, matching the capacity
and failure model of this two-node cluster.

The OpenBao root CA is not stored in this folder or in Git. The OpenBao
application declares a `Certificate`; cert-manager generates its private key
inside the `cert-manager` namespace and stores it in a Kubernetes Secret.

The separate `cloudflare-dns` application declares Let's Encrypt staging and
production `ClusterIssuer` resources after External Secrets is available. Its
Cloudflare user API token is delivered from OpenBao through a namespaced
`SecretStore`; no token, personal domain, zone ID, or email address is committed
there.

Create a dedicated token for this issuer with only:

- `Zone - Zone - Read`;
- `Zone - DNS - Edit`;
- access to one specific zone.

Use staging for integration checks. Workloads request production certificates
only after their DNS names and Gateway routes have been reviewed.
