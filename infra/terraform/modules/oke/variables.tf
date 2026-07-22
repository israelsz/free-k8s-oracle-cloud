variable "compartment_id" {
  description = "OCID of the compartment containing the OKE resources."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.compartment\\.", var.compartment_id))
    error_message = "compartment_id must be an OCI compartment OCID."
  }
}

variable "name" {
  description = "Display name of the OKE cluster."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,31}$", var.name))
    error_message = "name must use 3-32 lowercase letters, numbers, or hyphens."
  }
}

variable "kubernetes_version" {
  description = "Exact OKE control-plane and worker Kubernetes patch version."
  type        = string

  validation {
    condition     = var.kubernetes_version == "v1.35.2"
    error_message = "This milestone is deliberately pinned to OKE v1.35.2."
  }
}

variable "node_image_name" {
  description = "Exact AArch64 OKE image name discovered in the target region."
  type        = string

  validation {
    condition     = can(regex("^Oracle-Linux-8\\.[0-9]+-aarch64-[0-9]{4}\\.[0-9]{2}\\.[0-9]{2}-[0-9]+-OKE-1\\.35\\.2-[0-9]+$", var.node_image_name))
    error_message = "node_image_name must be an Oracle Linux 8 AArch64 OKE 1.35.2 image."
  }
}

variable "availability_domain" {
  description = "Santiago availability domain discovered with the OCI CLI."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9]+:SA-SANTIAGO-1-AD-1$", var.availability_domain))
    error_message = "availability_domain must be the tenancy-specific Santiago AD-1 name."
  }
}

variable "fault_domains" {
  description = "Fault domains OKE may spread the two workers across."
  type        = list(string)

  validation {
    condition = (
      length(var.fault_domains) >= 2 &&
      length(var.fault_domains) <= 3 &&
      alltrue([for fault_domain in var.fault_domains : can(regex("^FAULT-DOMAIN-[123]$", fault_domain))])
    )
    error_message = "fault_domains must contain two or three standard OCI fault-domain names."
  }
}

variable "vcn_id" {
  description = "OCID of the VCN containing the OKE cluster."
  type        = string
}

variable "api_subnet_id" {
  description = "OCID of the private regional Kubernetes API subnet."
  type        = string
}

variable "worker_subnet_id" {
  description = "OCID of the private regional worker subnet."
  type        = string
}

variable "pod_subnet_id" {
  description = "OCID of the private regional VCN-native pod subnet."
  type        = string
}

variable "load_balancer_subnet_id" {
  description = "OCID of the regional public load-balancer subnet."
  type        = string
}

variable "api_nsg_id" {
  description = "OCID of the Kubernetes API network security group."
  type        = string
}

variable "worker_nsg_id" {
  description = "OCID of the worker network security group."
  type        = string
}

variable "pod_nsg_id" {
  description = "OCID of the pod network security group."
  type        = string
}

variable "worker_count" {
  description = "Number of A1 worker nodes."
  type        = number

  validation {
    condition     = var.worker_count == 2
    error_message = "The zero-cost design requires exactly two workers."
  }
}

variable "worker_ocpus" {
  description = "OCPUs assigned to each A1 worker."
  type        = number

  validation {
    condition     = var.worker_ocpus == 2
    error_message = "Each worker must use exactly 2 OCPUs."
  }
}

variable "worker_memory_gbs" {
  description = "Memory assigned to each A1 worker in GB."
  type        = number

  validation {
    condition     = var.worker_memory_gbs == 12
    error_message = "Each worker must use exactly 12 GB of memory."
  }
}

variable "worker_boot_size_gbs" {
  description = "Boot-volume size of each A1 worker in GB."
  type        = number

  validation {
    condition     = var.worker_boot_size_gbs == 50
    error_message = "Each worker boot volume must remain exactly 50 GB."
  }
}

variable "max_pods_per_node" {
  description = "VCN-native pod-address capacity assigned to each worker."
  type        = number

  validation {
    condition     = var.max_pods_per_node == 31
    error_message = "This two-node design reserves exactly 31 pod addresses per node."
  }
}

variable "services_cidr" {
  description = "Virtual address range for Kubernetes Services; it must not overlap the VCN."
  type        = string

  validation {
    condition     = var.services_cidr == "10.96.0.0/16"
    error_message = "The Kubernetes Services CIDR is fixed at 10.96.0.0/16."
  }
}

variable "freeform_tags" {
  description = "Common non-sensitive tags applied to OKE resources and worker instances."
  type        = map(string)
  default     = {}
}
