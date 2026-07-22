output "operator_group_id" {
  description = "OCID of the least-privilege human operator group."
  value       = oci_identity_group.operators.id
}

output "operator_group_name" {
  description = "Name of the least-privilege human operator group."
  value       = oci_identity_group.operators.name
}

output "operator_policy_id" {
  description = "OCID of the Bastion and OKE access policy."
  value       = oci_identity_policy.operator_access.id
}
