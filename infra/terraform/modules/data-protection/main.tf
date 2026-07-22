data "oci_objectstorage_namespace" "this" {
  compartment_id = var.tenancy_ocid
}

resource "oci_kms_vault" "openbao" {
  compartment_id = var.project_compartment_id
  display_name   = "${var.name_prefix}-openbao"
  vault_type     = "DEFAULT"
  freeform_tags  = var.freeform_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_kms_key" "openbao_unseal" {
  compartment_id           = var.project_compartment_id
  display_name             = "${var.name_prefix}-openbao-unseal"
  management_endpoint      = oci_kms_vault.openbao.management_endpoint
  protection_mode          = "SOFTWARE"
  desired_state            = "ENABLED"
  is_auto_rotation_enabled = false
  freeform_tags            = var.freeform_tags

  key_shape {
    algorithm = "AES"
    length    = 32
  }

  lifecycle {
    prevent_destroy = true
  }
}

# OKE Basic does not provide pod-scoped OCI workload identity. OpenBao uses the
# instance principal of whichever worker currently runs its pod. The policy
# below still restricts that principal to one KMS key.
resource "oci_identity_dynamic_group" "oke_workers" {
  compartment_id = var.tenancy_ocid
  name           = "${replace(var.name_prefix, "-", "_")}_workers"
  description    = "OKE workers allowed to auto-unseal OpenBao"
  matching_rule  = "instance.compartment.id = '${var.project_compartment_id}'"
  freeform_tags  = var.freeform_tags
}

resource "oci_identity_policy" "openbao_unseal" {
  compartment_id = var.tenancy_ocid
  name           = "${var.name_prefix}-openbao-unseal"
  description    = "Allow the OKE workers to use only the OpenBao unseal key"
  freeform_tags  = var.freeform_tags

  statements = [
    "Allow dynamic-group id ${oci_identity_dynamic_group.oke_workers.id} to use keys in compartment id ${var.project_compartment_id} where target.key.id='${oci_kms_key.openbao_unseal.id}'",
  ]
}

resource "oci_objectstorage_bucket" "workload_backups" {
  compartment_id        = var.project_compartment_id
  namespace             = data.oci_objectstorage_namespace.this.namespace
  name                  = var.backup_bucket_name
  access_type           = "NoPublicAccess"
  storage_tier          = "Standard"
  auto_tiering          = "Disabled"
  versioning            = "Enabled"
  object_events_enabled = false
  freeform_tags         = merge(var.freeform_tags, { purpose = "workload-backups" })

  lifecycle {
    prevent_destroy = true
  }
}

# Lifecycle rules need an explicit regional Object Storage service grant. The
# grant is limited to this one bucket.
resource "oci_identity_policy" "backup_lifecycle" {
  compartment_id = var.tenancy_ocid
  name           = "${var.name_prefix}-backup-lifecycle"
  description    = "Let Object Storage expire old data in the workload backup bucket"
  freeform_tags  = var.freeform_tags

  statements = [
    "Allow service ${var.object_storage_service_principal} to manage object-family in compartment id ${var.project_compartment_id} where target.bucket.name='${oci_objectstorage_bucket.workload_backups.name}'",
  ]
}

resource "oci_objectstorage_object_lifecycle_policy" "workload_backups" {
  namespace = data.oci_objectstorage_namespace.this.namespace
  bucket    = oci_objectstorage_bucket.workload_backups.name

  rules {
    name        = "delete-backups-after-14-days"
    action      = "DELETE"
    target      = "objects"
    time_amount = "14"
    time_unit   = "DAYS"
    is_enabled  = true
  }

  rules {
    name        = "delete-previous-versions-after-2-days"
    action      = "DELETE"
    target      = "previous-object-versions"
    time_amount = "2"
    time_unit   = "DAYS"
    is_enabled  = true
  }

  rules {
    name        = "abort-incomplete-uploads-after-1-day"
    action      = "ABORT"
    target      = "multipart-uploads"
    time_amount = "1"
    time_unit   = "DAYS"
    is_enabled  = true
  }

  depends_on = [oci_identity_policy.backup_lifecycle]
}
