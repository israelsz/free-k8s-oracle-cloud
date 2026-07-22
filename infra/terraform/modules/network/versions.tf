terraform {
  required_version = ">= 1.12.1, < 2.0.0"

  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}
