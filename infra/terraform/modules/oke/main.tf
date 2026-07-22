resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = var.name
  type               = "BASIC_CLUSTER"
  vcn_id             = var.vcn_id
  freeform_tags      = var.freeform_tags

  cluster_pod_network_options {
    cni_type = "OCI_VCN_IP_NATIVE"
  }

  endpoint_config {
    is_public_ip_enabled = false
    nsg_ids              = [var.api_nsg_id]
    subnet_id            = var.api_subnet_id
  }

  options {
    ip_families           = ["IPv4"]
    service_lb_subnet_ids = [var.load_balancer_subnet_id]

    kubernetes_network_config {
      services_cidr = var.services_cidr
    }

    persistent_volume_config {
      freeform_tags = merge(var.freeform_tags, {
        storage-owner = "kubernetes"
      })
    }

    service_lb_config {
      backend_nsg_ids = [var.worker_nsg_id]
      freeform_tags = merge(var.freeform_tags, {
        traffic-owner = "kubernetes"
      })
    }
  }

  lifecycle {
    precondition {
      condition     = contains(data.oci_containerengine_cluster_option.regional.kubernetes_versions, var.kubernetes_version)
      error_message = "OKE ${var.kubernetes_version} is not currently available in this region. Query the regional OKE options and deliberately select a supported version."
    }
  }
}

resource "oci_containerengine_node_pool" "workers" {
  cluster_id         = oci_containerengine_cluster.this.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = "${var.name}-workers"
  node_shape         = "VM.Standard.A1.Flex"
  freeform_tags      = var.freeform_tags

  node_config_details {
    size                                = var.worker_count
    nsg_ids                             = [var.worker_nsg_id]
    is_pv_encryption_in_transit_enabled = true
    freeform_tags                       = var.freeform_tags

    placement_configs {
      availability_domain = var.availability_domain
      fault_domains       = var.fault_domains
      subnet_id           = var.worker_subnet_id
    }

    node_pool_pod_network_option_details {
      cni_type          = "OCI_VCN_IP_NATIVE"
      max_pods_per_node = var.max_pods_per_node
      pod_nsg_ids       = [var.pod_nsg_id]
      pod_subnet_ids    = [var.pod_subnet_id]
    }
  }

  node_shape_config {
    ocpus         = var.worker_ocpus
    memory_in_gbs = var.worker_memory_gbs
  }

  node_source_details {
    source_type             = "IMAGE"
    image_id                = local.node_image_id
    boot_volume_size_in_gbs = tostring(var.worker_boot_size_gbs)
  }

  node_pool_cycling_details {
    is_node_cycling_enabled = false
  }

  lifecycle {
    precondition {
      condition     = contains(data.oci_containerengine_node_pool_option.arm_ol8.shapes, "VM.Standard.A1.Flex")
      error_message = "VM.Standard.A1.Flex is not currently offered for this OKE version and region."
    }

    precondition {
      condition     = local.node_image_id != "UNAVAILABLE"
      error_message = "The pinned Arm OKE image is unavailable. Query the regional OKE options and deliberately select a replacement."
    }
  }
}
