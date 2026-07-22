resource "oci_identity_group" "operators" {
  compartment_id = var.tenancy_ocid
  name           = var.operator_group_name
  description    = "Least-privilege human access to the israheck Kubernetes API"
  freeform_tags  = var.freeform_tags
}

resource "oci_identity_user_group_membership" "operator" {
  group_id = oci_identity_group.operators.id
  user_id  = var.operator_user_ocid
}

resource "oci_identity_policy" "operator_access" {
  compartment_id = var.tenancy_ocid
  name           = "israheck-operator-access"
  description    = "Create constrained Bastion sessions and obtain an OKE kubeconfig"
  freeform_tags  = var.freeform_tags

  statements = [
    "Allow group id ${oci_identity_group.operators.id} to use bastion in compartment id ${var.project_compartment_id}",
    "Allow group id ${oci_identity_group.operators.id} to manage bastion-session in compartment id ${var.project_compartment_id} where ALL {target.bastion.ocid='${var.bastion_id}', target.bastion-session.type='port_forwarding', target.bastion-session.ip in ['${var.api_endpoint_cidr}'], target.bastion-session.port='6443'}",
    "Allow group id ${oci_identity_group.operators.id} to read vcn in compartment id ${var.project_compartment_id}",
    "Allow group id ${oci_identity_group.operators.id} to read subnet in compartment id ${var.project_compartment_id}",
    "Allow group id ${oci_identity_group.operators.id} to use clusters in compartment id ${var.project_compartment_id}",
  ]
}
