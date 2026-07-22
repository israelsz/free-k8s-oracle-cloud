resource "oci_bastion_bastion" "oke_api" {
  bastion_type                 = "standard"
  compartment_id               = var.compartment_id
  target_subnet_id             = var.target_subnet_id
  client_cidr_block_allow_list = var.client_cidr_block_allow_list
  dns_proxy_status             = "DISABLED"
  max_session_ttl_in_seconds   = var.max_session_ttl_in_seconds
  name                         = var.name
  freeform_tags                = var.freeform_tags
}
