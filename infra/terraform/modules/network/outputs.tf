output "vcn_id" {
  description = "VCN OCID."
  value       = oci_core_vcn.this.id
}

output "subnet_ids" {
  description = "Regional subnet OCIDs consumed by OKE, Bastion, and load balancers."
  value = {
    api           = oci_core_subnet.api.id
    workers       = oci_core_subnet.workers.id
    pods          = oci_core_subnet.pods.id
    load_balancer = oci_core_subnet.load_balancer.id
  }
}

output "network_security_group_ids" {
  description = "Role-specific NSG OCIDs attached by the OKE and GitOps layers."
  value = {
    api           = oci_core_network_security_group.api.id
    workers       = oci_core_network_security_group.workers.id
    pods          = oci_core_network_security_group.pods.id
    load_balancer = oci_core_network_security_group.load_balancer.id
  }
}

output "cidrs" {
  description = "Non-secret network map used by runbooks and policy checks."
  value = {
    vcn           = var.vcn_cidr
    api           = var.api_subnet_cidr
    workers       = var.worker_subnet_cidr
    pods          = var.pod_subnet_cidr
    load_balancer = var.load_balancer_subnet_cidr
  }
}

output "service_network_cidr" {
  description = "Regional OCI services CIDR selected by the service gateway."
  value       = data.oci_core_services.all.services[0].cidr_block
}
