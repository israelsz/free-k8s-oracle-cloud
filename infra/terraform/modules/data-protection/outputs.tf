output "openbao_kms" {
  description = "Non-secret OCI KMS settings consumed by the OpenBao Helm values."
  value = {
    vault_id                = oci_kms_vault.openbao.id
    key_id                  = oci_kms_key.openbao_unseal.id
    crypto_endpoint         = oci_kms_vault.openbao.crypto_endpoint
    management_endpoint     = oci_kms_vault.openbao.management_endpoint
    worker_dynamic_group_id = oci_identity_dynamic_group.oke_workers.id
  }
}

output "backup_bucket" {
  description = "Non-secret workload backup bucket settings."
  value = {
    name      = oci_objectstorage_bucket.workload_backups.name
    namespace = data.oci_objectstorage_namespace.this.namespace
  }
}
