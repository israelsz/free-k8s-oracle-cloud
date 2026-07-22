output "cluster_id" {
  description = "OCID of the OKE cluster."
  value       = oci_containerengine_cluster.this.id
}

output "node_pool_id" {
  description = "OCID of the two-node managed worker pool."
  value       = oci_containerengine_node_pool.workers.id
}

output "kubernetes_version" {
  description = "Kubernetes patch version used by the control plane and workers."
  value       = oci_containerengine_cluster.this.kubernetes_version
}

output "private_endpoint" {
  description = "Private Kubernetes API endpoint used through OCI Bastion."
  value       = try(oci_containerengine_cluster.this.endpoints[0].private_endpoint, null)
}

output "node_image_name" {
  description = "Pinned non-secret OKE worker image name."
  value       = var.node_image_name
}

output "node_shape" {
  description = "Fixed Always Free worker shape."
  value       = oci_containerengine_node_pool.workers.node_shape
}
