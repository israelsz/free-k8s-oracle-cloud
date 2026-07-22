resource "oci_budget_budget" "project" {
  compartment_id = var.tenancy_ocid
  amount         = var.monthly_budget_amount
  reset_period   = "MONTHLY"
  target_type    = "COMPARTMENT"
  targets        = [var.project_compartment_id]
  display_name   = "${var.name_prefix}-monthly-budget"
  description    = "Alert if the zero-cost Kubernetes compartment starts spending"
  freeform_tags  = var.freeform_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_budget_alert_rule" "actual_spend" {
  budget_id      = oci_budget_budget.project.id
  display_name   = "${var.name_prefix}-actual-spend"
  description    = "Actual spend reached one cent"
  type           = "ACTUAL"
  threshold_type = "ABSOLUTE"
  threshold      = 0.01
  recipients     = var.alert_email
  message        = "OCI reports actual spend in the israheck Kubernetes compartment. Review and stop the paid resource immediately."
  freeform_tags  = var.freeform_tags
}

resource "oci_budget_alert_rule" "forecast_spend" {
  budget_id      = oci_budget_budget.project.id
  display_name   = "${var.name_prefix}-forecast-spend"
  description    = "Forecast spend reached one cent"
  type           = "FORECAST"
  threshold_type = "ABSOLUTE"
  threshold      = 0.01
  recipients     = var.alert_email
  message        = "OCI forecasts spend in the israheck Kubernetes compartment. Review the planned usage before it becomes a charge."
  freeform_tags  = var.freeform_tags
}
