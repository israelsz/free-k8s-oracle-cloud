resource "oci_core_network_security_group" "api" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-api-nsg"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_network_security_group" "workers" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-workers-nsg"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_network_security_group" "pods" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-pods-nsg"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_network_security_group" "load_balancer" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-load-balancer-nsg"
  freeform_tags  = var.freeform_tags
}

locals {
  tcp_port_rules = {
    api_from_workers_6443 = {
      nsg_id      = oci_core_network_security_group.api.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.workers.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 6443
      max         = 6443
      description = "Worker nodes to Kubernetes API"
    }
    api_from_workers_12250 = {
      nsg_id      = oci_core_network_security_group.api.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.workers.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 12250
      max         = 12250
      description = "Worker nodes to OKE control plane"
    }
    api_from_pods_6443 = {
      nsg_id      = oci_core_network_security_group.api.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.pods.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 6443
      max         = 6443
      description = "Pods to Kubernetes API"
    }
    api_from_pods_12250 = {
      nsg_id      = oci_core_network_security_group.api.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.pods.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 12250
      max         = 12250
      description = "Pods to OKE control plane"
    }
    api_from_bastion_6443 = {
      nsg_id      = oci_core_network_security_group.api.id
      direction   = "INGRESS"
      peer        = var.api_subnet_cidr
      peer_type   = "CIDR_BLOCK"
      min         = 6443
      max         = 6443
      description = "OCI Bastion private endpoint to Kubernetes API"
    }
    api_to_oci_443 = {
      nsg_id      = oci_core_network_security_group.api.id
      direction   = "EGRESS"
      peer        = data.oci_core_services.all.services[0].cidr_block
      peer_type   = "SERVICE_CIDR_BLOCK"
      min         = 443
      max         = 443
      description = "Kubernetes API endpoint to OKE services"
    }
    api_to_workers_10250 = {
      nsg_id      = oci_core_network_security_group.api.id
      direction   = "EGRESS"
      peer        = oci_core_network_security_group.workers.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 10250
      max         = 10250
      description = "Kubernetes API to kubelet"
    }
    workers_from_api_10250 = {
      nsg_id      = oci_core_network_security_group.workers.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.api.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 10250
      max         = 10250
      description = "Kubernetes API to kubelet"
    }
    workers_from_lb_nodeports = {
      nsg_id      = oci_core_network_security_group.workers.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.load_balancer.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 30000
      max         = 32767
      description = "Load balancer to Kubernetes NodePorts"
    }
    workers_from_lb_health = {
      nsg_id      = oci_core_network_security_group.workers.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.load_balancer.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 10256
      max         = 10256
      description = "Load balancer to kube-proxy health port"
    }
    workers_to_api_6443 = {
      nsg_id      = oci_core_network_security_group.workers.id
      direction   = "EGRESS"
      peer        = oci_core_network_security_group.api.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 6443
      max         = 6443
      description = "Worker nodes to Kubernetes API"
    }
    workers_to_api_12250 = {
      nsg_id      = oci_core_network_security_group.workers.id
      direction   = "EGRESS"
      peer        = oci_core_network_security_group.api.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 12250
      max         = 12250
      description = "Worker nodes to OKE control plane"
    }
    pods_to_api_6443 = {
      nsg_id      = oci_core_network_security_group.pods.id
      direction   = "EGRESS"
      peer        = oci_core_network_security_group.api.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 6443
      max         = 6443
      description = "Pods to Kubernetes API"
    }
    pods_to_api_12250 = {
      nsg_id      = oci_core_network_security_group.pods.id
      direction   = "EGRESS"
      peer        = oci_core_network_security_group.api.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 12250
      max         = 12250
      description = "Pods to OKE control plane"
    }
    pods_to_internet_443 = {
      nsg_id      = oci_core_network_security_group.pods.id
      direction   = "EGRESS"
      peer        = "0.0.0.0/0"
      peer_type   = "CIDR_BLOCK"
      min         = 443
      max         = 443
      description = "Pod HTTPS egress through NAT; NetworkPolicy restricts workloads further"
    }
    lb_to_workers_nodeports = {
      nsg_id      = oci_core_network_security_group.load_balancer.id
      direction   = "EGRESS"
      peer        = oci_core_network_security_group.workers.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 30000
      max         = 32767
      description = "Load balancer to Kubernetes NodePorts"
    }
    lb_to_workers_health = {
      nsg_id      = oci_core_network_security_group.load_balancer.id
      direction   = "EGRESS"
      peer        = oci_core_network_security_group.workers.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      min         = 10256
      max         = 10256
      description = "Load balancer to kube-proxy health port"
    }
  }

  tcp_all_rules = {
    workers_to_oci = {
      nsg_id      = oci_core_network_security_group.workers.id
      direction   = "EGRESS"
      peer        = data.oci_core_services.all.services[0].cidr_block
      peer_type   = "SERVICE_CIDR_BLOCK"
      description = "Workers to OKE, OCIR, and OCI services"
    }
    workers_to_internet = {
      nsg_id      = oci_core_network_security_group.workers.id
      direction   = "EGRESS"
      peer        = "0.0.0.0/0"
      peer_type   = "CIDR_BLOCK"
      description = "Worker TCP egress through NAT"
    }
    pods_to_oci = {
      nsg_id      = oci_core_network_security_group.pods.id
      direction   = "EGRESS"
      peer        = data.oci_core_services.all.services[0].cidr_block
      peer_type   = "SERVICE_CIDR_BLOCK"
      description = "Pods to OCI regional services"
    }
  }

  all_protocol_rules = {
    api_to_pods = {
      nsg_id      = oci_core_network_security_group.api.id
      direction   = "EGRESS"
      peer        = oci_core_network_security_group.pods.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      description = "Kubernetes control plane to VCN-native pods"
    }
    workers_from_workers = {
      nsg_id      = oci_core_network_security_group.workers.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.workers.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      description = "Worker-to-worker communication"
    }
    workers_from_pods = {
      nsg_id      = oci_core_network_security_group.workers.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.pods.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      description = "VCN-native pods to worker nodes"
    }
    workers_to_workers = {
      nsg_id      = oci_core_network_security_group.workers.id
      direction   = "EGRESS"
      peer        = oci_core_network_security_group.workers.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      description = "Worker-to-worker communication"
    }
    workers_to_pods = {
      nsg_id      = oci_core_network_security_group.workers.id
      direction   = "EGRESS"
      peer        = oci_core_network_security_group.pods.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      description = "Worker nodes to VCN-native pods"
    }
    pods_from_api = {
      nsg_id      = oci_core_network_security_group.pods.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.api.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      description = "Kubernetes control plane to VCN-native pods"
    }
    pods_from_workers = {
      nsg_id      = oci_core_network_security_group.pods.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.workers.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      description = "Worker nodes to VCN-native pods"
    }
    pods_from_pods = {
      nsg_id      = oci_core_network_security_group.pods.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.pods.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      description = "Pod-to-pod communication; Kubernetes NetworkPolicy restricts workloads"
    }
    pods_to_pods = {
      nsg_id      = oci_core_network_security_group.pods.id
      direction   = "EGRESS"
      peer        = oci_core_network_security_group.pods.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      description = "Pod-to-pod communication; Kubernetes NetworkPolicy restricts workloads"
    }
  }

  icmp_rules = {
    api_from_workers_path = {
      nsg_id      = oci_core_network_security_group.api.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.workers.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      description = "Path MTU discovery from workers"
    }
    api_to_workers_path = {
      nsg_id      = oci_core_network_security_group.api.id
      direction   = "EGRESS"
      peer        = oci_core_network_security_group.workers.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      description = "Path MTU discovery to workers"
    }
    workers_from_api_path = {
      nsg_id      = oci_core_network_security_group.workers.id
      direction   = "INGRESS"
      peer        = oci_core_network_security_group.api.id
      peer_type   = "NETWORK_SECURITY_GROUP"
      description = "Path MTU discovery from Kubernetes API"
    }
    workers_to_internet_path = {
      nsg_id      = oci_core_network_security_group.workers.id
      direction   = "EGRESS"
      peer        = "0.0.0.0/0"
      peer_type   = "CIDR_BLOCK"
      description = "Path MTU discovery"
    }
    pods_to_oci_path = {
      nsg_id      = oci_core_network_security_group.pods.id
      direction   = "EGRESS"
      peer        = data.oci_core_services.all.services[0].cidr_block
      peer_type   = "SERVICE_CIDR_BLOCK"
      description = "Path MTU discovery to OCI services"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "tcp_port" {
  for_each = local.tcp_port_rules

  network_security_group_id = each.value.nsg_id
  direction                 = each.value.direction
  protocol                  = "6"
  source                    = each.value.direction == "INGRESS" ? each.value.peer : null
  source_type               = each.value.direction == "INGRESS" ? each.value.peer_type : null
  destination               = each.value.direction == "EGRESS" ? each.value.peer : null
  destination_type          = each.value.direction == "EGRESS" ? each.value.peer_type : null
  description               = each.value.description
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = each.value.min
      max = each.value.max
    }
  }
}

resource "oci_core_network_security_group_security_rule" "tcp_all" {
  for_each = local.tcp_all_rules

  network_security_group_id = each.value.nsg_id
  direction                 = each.value.direction
  protocol                  = "6"
  source                    = each.value.direction == "INGRESS" ? each.value.peer : null
  source_type               = each.value.direction == "INGRESS" ? each.value.peer_type : null
  destination               = each.value.direction == "EGRESS" ? each.value.peer : null
  destination_type          = each.value.direction == "EGRESS" ? each.value.peer_type : null
  description               = each.value.description
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "all_protocols" {
  for_each = local.all_protocol_rules

  network_security_group_id = each.value.nsg_id
  direction                 = each.value.direction
  protocol                  = "all"
  source                    = each.value.direction == "INGRESS" ? each.value.peer : null
  source_type               = each.value.direction == "INGRESS" ? each.value.peer_type : null
  destination               = each.value.direction == "EGRESS" ? each.value.peer : null
  destination_type          = each.value.direction == "EGRESS" ? each.value.peer_type : null
  description               = each.value.description
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "icmp" {
  for_each = local.icmp_rules

  network_security_group_id = each.value.nsg_id
  direction                 = each.value.direction
  protocol                  = "1"
  source                    = each.value.direction == "INGRESS" ? each.value.peer : null
  source_type               = each.value.direction == "INGRESS" ? each.value.peer_type : null
  destination               = each.value.direction == "EGRESS" ? each.value.peer : null
  destination_type          = each.value.direction == "EGRESS" ? each.value.peer_type : null
  description               = each.value.description
  stateless                 = false

  icmp_options {
    type = 3
    code = 4
  }
}

resource "oci_core_network_security_group_security_rule" "load_balancer_https" {
  for_each = var.public_ingress_cidrs

  network_security_group_id = oci_core_network_security_group.load_balancer.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  description               = "HTTPS from Cloudflare proxy network"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}
