output "planned_capacity" {
  description = "Non-secret cost-envelope summary used during reviews."
  value       = local.planned_capacity
}

output "base_domain" {
  description = "Public base domain managed by this stack."
  value       = var.base_domain
}

output "project_compartment_id" {
  description = "Compartment containing the platform resources."
  value       = oci_identity_compartment.project.id
}

output "network" {
  description = "Non-secret network identifiers consumed by OKE and bootstrap tooling."
  value = {
    vcn_id                     = module.network.vcn_id
    subnet_ids                 = module.network.subnet_ids
    network_security_group_ids = module.network.network_security_group_ids
    cidrs                      = module.network.cidrs
  }
}

output "oke" {
  description = "Non-secret OKE identifiers and pinned runtime choices."
  value = {
    cluster_id         = module.oke.cluster_id
    node_pool_id       = module.oke.node_pool_id
    kubernetes_version = module.oke.kubernetes_version
    private_endpoint   = module.oke.private_endpoint
    node_image_name    = module.oke.node_image_name
    node_shape         = module.oke.node_shape
  }
}

output "access" {
  description = "Non-secret values used to open a temporary Kubernetes API tunnel."
  value = {
    bastion_id                 = module.access.bastion_id
    bastion_private_endpoint   = module.access.private_endpoint_ip_address
    client_cidrs               = module.access.client_cidr_block_allow_list
    max_session_ttl_in_seconds = module.access.max_session_ttl_in_seconds
  }
}

output "identity" {
  description = "Non-secret operator IAM identifiers."
  value = {
    operator_group_id   = module.identity.operator_group_id
    operator_group_name = module.identity.operator_group_name
    operator_policy_id  = module.identity.operator_policy_id
  }
}

output "data_protection" {
  description = "Non-secret KMS and backup settings consumed during GitOps bootstrap."
  value = {
    openbao_kms   = module.data_protection.openbao_kms
    backup_bucket = module.data_protection.backup_bucket
  }
}

output "cost_guardrails" {
  description = "Non-secret identifiers for the compartment budget and alerts."
  value = {
    budget_id      = module.cost_guardrails.budget_id
    alert_rule_ids = module.cost_guardrails.alert_rule_ids
  }
}
