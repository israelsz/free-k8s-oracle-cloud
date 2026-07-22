check "always_free_compute_envelope" {
  assert {
    condition     = local.planned_capacity.total_ocpus == 4 && local.planned_capacity.total_memory_gbs == 24
    error_message = "The worker pool must total exactly 4 OCPUs and 24 GB memory."
  }
}

check "always_free_storage_envelope" {
  assert {
    condition     = local.planned_capacity.provisioned_disk_gbs == 150 && local.planned_capacity.storage_reserve_gbs == 50
    error_message = "The plan must provision 150 GB and leave a 50 GB replacement reserve."
  }
}

check "oke_runtime_envelope" {
  assert {
    condition = (
      var.kubernetes_version == "v1.35.2" &&
      var.max_pods_per_node == 31 &&
      endswith(var.availability_domain, ":SA-SANTIAGO-1-AD-1")
    )
    error_message = "OKE must use the reviewed Kubernetes version, pod capacity, and Santiago placement."
  }
}
