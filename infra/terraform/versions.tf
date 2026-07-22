terraform {
  required_version = "~> 1.15.8"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "8.23.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.22.0"
    }
  }
}
