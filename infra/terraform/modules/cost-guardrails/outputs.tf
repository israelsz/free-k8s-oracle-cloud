output "budget_id" {
  description = "OCID of the monthly compartment budget."
  value       = oci_budget_budget.project.id
}

output "alert_rule_ids" {
  description = "OCIDs of the actual and forecast spend alert rules."
  value = {
    actual   = oci_budget_alert_rule.actual_spend.id
    forecast = oci_budget_alert_rule.forecast_spend.id
  }
}
