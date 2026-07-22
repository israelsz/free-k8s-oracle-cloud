terraform {
  # Values live in backend.hcl because the bucket and namespace are
  # account-specific metadata. Authentication comes from the local OCI profile.
  backend "oci" {}
}
