variable "compartment_id" {
  description = "OCID of the project compartment."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.compartment\\.", var.compartment_id))
    error_message = "compartment_id must be an OCI compartment OCID."
  }
}

variable "name" {
  description = "Alphanumeric display name required by OCI Bastion."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9]{2,31}$", var.name))
    error_message = "name must use 3-32 alphanumeric characters."
  }
}

variable "target_subnet_id" {
  description = "Private API subnet hosting the Bastion private endpoint."
  type        = string
}

variable "client_cidr_block_allow_list" {
  description = "Small list of administrator public IPv4 /32 addresses allowed to connect."
  type        = list(string)

  validation {
    condition = (
      length(var.client_cidr_block_allow_list) >= 1 &&
      length(var.client_cidr_block_allow_list) <= 5 &&
      alltrue([
        for cidr in var.client_cidr_block_allow_list :
        can(cidrnetmask(cidr)) && can(regex("/32$", cidr)) && cidr != "0.0.0.0/32"
      ])
    )
    error_message = "Provide one to five explicit public IPv4 /32 CIDRs; broad ranges are not allowed."
  }
}

variable "max_session_ttl_in_seconds" {
  description = "Maximum lifetime of any Bastion session."
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_ttl_in_seconds == 3600
    error_message = "Administrative Bastion sessions are fixed at a one-hour maximum."
  }
}

variable "freeform_tags" {
  description = "Common non-sensitive tags."
  type        = map(string)
  default     = {}
}
