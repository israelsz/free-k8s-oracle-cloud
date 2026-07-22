output "bastion_id" {
  description = "OCID used when creating a temporary port-forwarding session."
  value       = oci_bastion_bastion.oke_api.id
}

output "private_endpoint_ip_address" {
  description = "Private endpoint from which Bastion reaches the Kubernetes API."
  value       = oci_bastion_bastion.oke_api.private_endpoint_ip_address
}

output "max_session_ttl_in_seconds" {
  description = "Maximum lifetime permitted for a temporary Bastion session."
  value       = oci_bastion_bastion.oke_api.max_session_ttl_in_seconds
}

output "client_cidr_block_allow_list" {
  description = "Administrator source ranges accepted by Bastion."
  value       = oci_bastion_bastion.oke_api.client_cidr_block_allow_list
}
