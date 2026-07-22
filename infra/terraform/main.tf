# The project compartment is deliberately protected from ordinary `terraform
# destroy`. Decommissioning the platform requires a reviewed source change.
resource "oci_identity_compartment" "project" {
  compartment_id = var.tenancy_ocid
  name           = "israheck-prod"
  description    = "Production-disciplined personal Kubernetes platform"
  enable_delete  = true
  freeform_tags  = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

# This endpoint is public metadata published by Cloudflare and requires no API
# token. Restricting the origin NSG prevents clients from bypassing Cloudflare.
data "cloudflare_ip_ranges" "proxy" {}

data "oci_identity_user" "operator" {
  user_id = var.operator_user_ocid
}

module "network" {
  source = "./modules/network"

  compartment_id = oci_identity_compartment.project.id
  name_prefix    = var.cluster_name

  vcn_cidr                  = local.network_cidrs.vcn
  api_subnet_cidr           = local.network_cidrs.api
  worker_subnet_cidr        = local.network_cidrs.workers
  pod_subnet_cidr           = local.network_cidrs.pods
  load_balancer_subnet_cidr = local.network_cidrs.load_balancer
  public_ingress_cidrs      = toset(data.cloudflare_ip_ranges.proxy.ipv4_cidrs)
  freeform_tags             = local.common_tags
}

module "data_protection" {
  source = "./modules/data-protection"

  tenancy_ocid                     = var.tenancy_ocid
  project_compartment_id           = oci_identity_compartment.project.id
  name_prefix                      = var.cluster_name
  backup_bucket_name               = local.backup_bucket_name
  object_storage_service_principal = local.object_storage_service_principal
  freeform_tags                    = local.common_tags
}

module "oke" {
  source = "./modules/oke"

  compartment_id      = oci_identity_compartment.project.id
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  node_image_name     = var.node_image_name
  availability_domain = var.availability_domain
  fault_domains       = local.worker_fault_domains

  vcn_id                  = module.network.vcn_id
  api_subnet_id           = module.network.subnet_ids.api
  worker_subnet_id        = module.network.subnet_ids.workers
  pod_subnet_id           = module.network.subnet_ids.pods
  load_balancer_subnet_id = module.network.subnet_ids.load_balancer
  api_nsg_id              = module.network.network_security_group_ids.api
  worker_nsg_id           = module.network.network_security_group_ids.workers
  pod_nsg_id              = module.network.network_security_group_ids.pods

  worker_count         = var.worker_count
  worker_ocpus         = var.worker_ocpus
  worker_memory_gbs    = var.worker_memory_gbs
  worker_boot_size_gbs = var.worker_boot_size_gbs
  max_pods_per_node    = var.max_pods_per_node
  services_cidr        = local.kubernetes_services_cidr
  freeform_tags        = local.common_tags
}

module "access" {
  source = "./modules/access"

  compartment_id               = oci_identity_compartment.project.id
  name                         = "israheckprod"
  target_subnet_id             = module.network.subnet_ids.api
  client_cidr_block_allow_list = var.bastion_client_cidrs
  max_session_ttl_in_seconds   = 3600
  freeform_tags                = local.common_tags
}

module "identity" {
  source = "./modules/identity"

  tenancy_ocid           = var.tenancy_ocid
  project_compartment_id = oci_identity_compartment.project.id
  operator_user_ocid     = var.operator_user_ocid
  operator_group_name    = "israheck-operators"
  bastion_id             = module.access.bastion_id
  api_endpoint_cidr      = "${split(":", module.oke.private_endpoint)[0]}/32"
  freeform_tags          = local.common_tags
}

module "cost_guardrails" {
  source = "./modules/cost-guardrails"

  tenancy_ocid           = var.tenancy_ocid
  project_compartment_id = oci_identity_compartment.project.id
  monthly_budget_amount  = var.monthly_budget_amount
  alert_email            = data.oci_identity_user.operator.email
  name_prefix            = var.cluster_name
  freeform_tags          = local.common_tags
}

# Remaining planned composition:
#
# module "cloudflare" { ... }
