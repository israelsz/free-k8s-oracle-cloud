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
