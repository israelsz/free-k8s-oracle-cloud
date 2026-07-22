variable "tenancy_ocid" {
  description = "OCI tenancy OCID containing the operator group and policy."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.tenancy\\.", var.tenancy_ocid))
    error_message = "tenancy_ocid must be an OCI tenancy OCID."
  }
}

variable "project_compartment_id" {
  description = "OCID of the compartment containing OKE and Bastion."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.compartment\\.", var.project_compartment_id))
    error_message = "project_compartment_id must be an OCI compartment OCID."
  }
}

variable "operator_user_ocid" {
  description = "OCID of the human user placed in the least-privilege operator group."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.user\\.", var.operator_user_ocid))
    error_message = "operator_user_ocid must be an OCI user OCID."
  }
}

variable "operator_group_name" {
  description = "Name of the default-domain IAM group for human cluster operators."
  type        = string
  default     = "israheck-operators"

  validation {
    condition     = var.operator_group_name == "israheck-operators"
    error_message = "The reviewed operator group name is israheck-operators."
  }
}

variable "bastion_id" {
  description = "OCID of the only Bastion operators may use."
  type        = string
}

variable "api_endpoint_cidr" {
  description = "Exact private API endpoint /32 to which Bastion sessions are restricted on TCP/6443."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.api_endpoint_cidr)) && can(regex("^10\\.20\\.0\\.[0-9]+/32$", var.api_endpoint_cidr))
    error_message = "Bastion operator access must target one private API endpoint /32."
  }
}

variable "freeform_tags" {
  description = "Common non-sensitive tags."
  type        = map(string)
  default     = {}
}
