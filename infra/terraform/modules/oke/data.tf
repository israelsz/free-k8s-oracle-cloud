data "oci_containerengine_cluster_option" "regional" {
  cluster_option_id              = "all"
  should_list_all_patch_versions = true
}

data "oci_containerengine_node_pool_option" "arm_ol8" {
  node_pool_option_id            = "all"
  node_pool_k8s_version          = var.kubernetes_version
  node_pool_os_arch              = "AARCH64"
  node_pool_os_type              = "OL8"
  should_list_all_patch_versions = true
}

locals {
  matching_node_images = [
    for source in data.oci_containerengine_node_pool_option.arm_ol8.sources : source
    if source.source_type == "IMAGE" && source.source_name == var.node_image_name
  ]

  node_image_id = try(one(local.matching_node_images).image_id, "UNAVAILABLE")
}
