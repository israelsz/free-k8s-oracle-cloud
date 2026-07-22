provider "oci" {
  auth                = var.oci_auth
  region              = var.region
  config_file_profile = var.oci_config_profile
}

# Authentication is read from CLOUDFLARE_API_TOKEN. Never model the token as an
# Terraform variable because variable values and provider configuration can enter
# plans or state.
provider "cloudflare" {}
