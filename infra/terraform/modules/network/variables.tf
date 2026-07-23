variable "compartment_id" {
  description = "OCID of the project compartment."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.compartment\\.", var.compartment_id))
    error_message = "compartment_id must be an OCI compartment OCID."
  }
}

variable "name_prefix" {
  description = "Short prefix used for network resource display names."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,23}$", var.name_prefix))
    error_message = "name_prefix must use 3-24 lowercase letters, numbers, or hyphens."
  }
}

variable "vcn_cidr" {
  description = "IPv4 CIDR for the complete VCN."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vcn_cidr))
    error_message = "vcn_cidr must be a valid IPv4 CIDR."
  }
}

variable "api_subnet_cidr" {
  description = "Private regional subnet for the OKE Kubernetes API endpoint."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.api_subnet_cidr))
    error_message = "api_subnet_cidr must be a valid IPv4 CIDR."
  }
}

variable "worker_subnet_cidr" {
  description = "Private regional subnet for managed worker nodes."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.worker_subnet_cidr))
    error_message = "worker_subnet_cidr must be a valid IPv4 CIDR."
  }
}

variable "pod_subnet_cidr" {
  description = "Private regional subnet for VCN-native pod addresses."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.pod_subnet_cidr))
    error_message = "pod_subnet_cidr must be a valid IPv4 CIDR."
  }
}

variable "load_balancer_subnet_cidr" {
  description = "Public regional subnet for the single OCI load balancer."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.load_balancer_subnet_cidr))
    error_message = "load_balancer_subnet_cidr must be a valid IPv4 CIDR."
  }
}

variable "freeform_tags" {
  description = "Common non-sensitive tags applied to every network resource."
  type        = map(string)
  default     = {}
}
