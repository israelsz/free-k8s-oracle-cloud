variable "tenancy_ocid" {
  description = "OCI tenancy OCID containing tenancy-wide IAM resources."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.tenancy\\.", var.tenancy_ocid))
    error_message = "tenancy_ocid must be an OCI tenancy OCID."
  }
}

variable "project_compartment_id" {
  description = "Compartment containing the cluster, KMS key, and backup bucket."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.compartment\\.", var.project_compartment_id))
    error_message = "project_compartment_id must be an OCI compartment OCID."
  }
}

variable "name_prefix" {
  description = "Stable prefix for project resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,31}$", var.name_prefix))
    error_message = "name_prefix must use 3-32 lowercase letters, numbers, or hyphens."
  }
}

variable "backup_bucket_name" {
  description = "Private Object Storage bucket used for workload backups."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,62}$", var.backup_bucket_name))
    error_message = "backup_bucket_name must be a valid lowercase Object Storage bucket name."
  }
}

variable "object_storage_service_principal" {
  description = "Regional Object Storage service principal allowed to execute lifecycle rules."
  type        = string

  validation {
    condition     = can(regex("^objectstorage-[a-z]{2}-[a-z0-9-]+-[0-9]+$", var.object_storage_service_principal))
    error_message = "object_storage_service_principal must use an OCI region identifier, such as objectstorage-sa-santiago-1."
  }
}

variable "freeform_tags" {
  description = "Common non-sensitive tags."
  type        = map(string)
  default     = {}
}
