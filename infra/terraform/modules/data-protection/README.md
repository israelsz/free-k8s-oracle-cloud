# Data-protection module

Owns the default OCI KMS vault, the software-protected OpenBao auto-unseal key,
the worker dynamic group and key-use policy, plus the private workload-backup
Object Storage bucket and lifecycle rules. The manually created Terraform state
bucket stays outside this module.

The bucket keeps object versions, deletes current backups after 14 days,
deletes previous versions after another 2 days, and aborts incomplete multipart
uploads after 1 day. Application backup tools still use a seven-day recovery
window; the bucket rules are a storage-usage backstop.

This module intentionally does not create an S3-compatible Customer Secret Key.
Terraform would retain that secret in its state. The backup writer credential
will be created interactively after OpenBao is initialized, then stored in
OpenBao instead of Git or Terraform state.

OpenBao's 50 GB PVC is configured from GitOps. The OCI CSI driver creates the
actual block volume, while the Terraform root still counts those 50 GB in its
free-tier storage checks.
