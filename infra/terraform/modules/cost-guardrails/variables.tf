variable "tenancy_ocid" {
  description = "OCI tenancy OCID where the budget is created."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.tenancy\\.", var.tenancy_ocid))
    error_message = "tenancy_ocid must be an OCI tenancy OCID."
  }
}

variable "project_compartment_id" {
  description = "Compartment whose spending the budget tracks."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.compartment\\.", var.project_compartment_id))
    error_message = "project_compartment_id must be an OCI compartment OCID."
  }
}

variable "monthly_budget_amount" {
  description = "Monthly compartment budget in the tenancy billing currency."
  type        = number

  validation {
    condition     = var.monthly_budget_amount == 1
    error_message = "The zero-cost guardrail budget must remain 1."
  }
}

variable "alert_email" {
  description = "Email address that receives actual and forecast spending alerts."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[^@ ]+@[^@ ]+\\.[^@ ]+$", var.alert_email))
    error_message = "alert_email must be a valid email address."
  }
}

variable "name_prefix" {
  description = "Stable prefix for cost resources."
  type        = string
}

variable "freeform_tags" {
  description = "Common non-sensitive tags."
  type        = map(string)
  default     = {}
}
