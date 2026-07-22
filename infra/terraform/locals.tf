locals {
  common_tags = {
    managed-by  = "terraform"
    project     = "israheck-k8s"
    environment = "production"
    cost-policy = "always-free"
  }

  network_cidrs = {
    vcn           = "10.20.0.0/16"
    api           = "10.20.0.0/28"
    workers       = "10.20.1.0/24"
    pods          = "10.20.2.0/24"
    load_balancer = "10.20.3.0/24"
  }

  worker_fault_domains = [
    "FAULT-DOMAIN-1",
    "FAULT-DOMAIN-2",
    "FAULT-DOMAIN-3",
  ]

  kubernetes_services_cidr = "10.96.0.0/16"

  backup_bucket_name               = "israheck-prod-workload-backups"
  object_storage_service_principal = "objectstorage-scl"

  planned_capacity = {
    workers              = var.worker_count
    total_ocpus          = var.worker_count * var.worker_ocpus
    total_memory_gbs     = var.worker_count * var.worker_memory_gbs
    worker_boot_gbs      = var.worker_count * var.worker_boot_size_gbs
    openbao_block_gbs    = var.openbao_volume_size_gbs
    provisioned_disk_gbs = (var.worker_count * var.worker_boot_size_gbs) + var.openbao_volume_size_gbs
    storage_reserve_gbs  = 200 - ((var.worker_count * var.worker_boot_size_gbs) + var.openbao_volume_size_gbs)
  }
}
