variable "tenancy_ocid" {
  description = "OCI tenancy OCID used for tenancy-scoped identity resources."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.tenancy\\.", var.tenancy_ocid))
    error_message = "tenancy_ocid must be an OCI tenancy OCID."
  }
}

variable "region" {
  description = "OCI region where the platform will run."
  type        = string

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+-[0-9]+$", var.region))
    error_message = "region must look like an OCI region, for example sa-santiago-1."
  }
}

variable "oci_config_profile" {
  description = "Local OCI CLI profile name. This is not a credential."
  type        = string
  default     = "israheck"
}

variable "oci_auth" {
  description = "OCI provider authentication mode. Humans use a short-lived CLI session."
  type        = string
  default     = "SecurityToken"

  validation {
    condition     = contains(["SecurityToken", "ApiKey"], var.oci_auth)
    error_message = "oci_auth must be SecurityToken or ApiKey."
  }
}

variable "operator_user_ocid" {
  description = "OCI user OCID added to the least-privilege cluster operator group."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.user\\.", var.operator_user_ocid))
    error_message = "operator_user_ocid must be an OCI user OCID."
  }
}

variable "base_domain" {
  description = "Cloudflare-managed public base domain."
  type        = string
  default     = "israheck.com"

  validation {
    condition     = var.base_domain == "israheck.com"
    error_message = "This production stack is intentionally limited to israheck.com."
  }
}

variable "cluster_name" {
  description = "OKE cluster display name."
  type        = string
  default     = "israheck-prod"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,31}$", var.cluster_name))
    error_message = "cluster_name must use 3-32 lowercase letters, numbers, or hyphens."
  }
}

variable "availability_domain" {
  description = "Tenancy-specific Santiago availability domain discovered with the OCI CLI."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9]+:SA-SANTIAGO-1-AD-1$", var.availability_domain))
    error_message = "availability_domain must be the tenancy-specific Santiago AD-1 name."
  }
}

variable "kubernetes_version" {
  description = "Exact supported OKE patch version."
  type        = string
  default     = "v1.35.2"

  validation {
    condition     = var.kubernetes_version == "v1.35.2"
    error_message = "The reviewed OKE version is currently fixed at v1.35.2."
  }
}

variable "node_image_name" {
  description = "Exact AArch64 OKE image name discovered in Santiago."
  type        = string
  default     = "Oracle-Linux-8.10-aarch64-2026.06.15-0-OKE-1.35.2-1505"

  validation {
    condition     = var.node_image_name == "Oracle-Linux-8.10-aarch64-2026.06.15-0-OKE-1.35.2-1505"
    error_message = "The node image must match the latest image reviewed on 2026-07-21."
  }
}

variable "max_pods_per_node" {
  description = "Maximum VCN-native pod addresses reserved per worker."
  type        = number
  default     = 31

  validation {
    condition     = var.max_pods_per_node == 31
    error_message = "The reviewed pod-address budget is fixed at 31 per node."
  }
}

variable "bastion_client_cidrs" {
  description = "Administrator public IPv4 /32 CIDRs allowed to open Bastion sessions."
  type        = list(string)

  validation {
    condition = (
      length(var.bastion_client_cidrs) >= 1 &&
      length(var.bastion_client_cidrs) <= 5 &&
      alltrue([
        for cidr in var.bastion_client_cidrs :
        can(cidrnetmask(cidr)) && can(regex("/32$", cidr)) && cidr != "0.0.0.0/32"
      ])
    )
    error_message = "bastion_client_cidrs must contain one to five explicit public IPv4 /32 CIDRs."
  }
}

variable "worker_count" {
  description = "Number of Ampere workers. Fixed to preserve the planned topology."
  type        = number
  default     = 2

  validation {
    condition     = var.worker_count == 2
    error_message = "The zero-cost design requires exactly two workers."
  }
}

variable "worker_ocpus" {
  description = "OCPUs per VM.Standard.A1.Flex worker."
  type        = number
  default     = 2

  validation {
    condition     = var.worker_ocpus == 2
    error_message = "The zero-cost design requires exactly 2 OCPUs per worker."
  }
}

variable "worker_memory_gbs" {
  description = "Memory in GB per worker."
  type        = number
  default     = 12

  validation {
    condition     = var.worker_memory_gbs == 12
    error_message = "The zero-cost design requires exactly 12 GB per worker."
  }
}

variable "worker_boot_size_gbs" {
  description = "Boot-volume size for each worker."
  type        = number
  default     = 50

  validation {
    condition     = var.worker_boot_size_gbs == 50
    error_message = "Worker boot volumes must remain exactly 50 GB."
  }
}

variable "openbao_volume_size_gbs" {
  description = "Size of the only planned general OCI Block Volume."
  type        = number
  default     = 50

  validation {
    condition     = var.openbao_volume_size_gbs == 50
    error_message = "The approved OpenBao Block Volume must remain exactly 50 GB."
  }
}

variable "object_storage_soft_limit_gbs" {
  description = "Operational ceiling for state and backup objects."
  type        = number
  default     = 8

  validation {
    condition     = var.object_storage_soft_limit_gbs > 0 && var.object_storage_soft_limit_gbs <= 8
    error_message = "The Object Storage operational ceiling cannot exceed 8 GB."
  }
}

variable "monthly_budget_amount" {
  description = "Monthly budget in the tenancy billing currency; budgets alert but do not stop spending."
  type        = number
  default     = 1

  validation {
    condition     = var.monthly_budget_amount == 1
    error_message = "The initial alert threshold must remain 1 in the tenancy billing currency."
  }
}
