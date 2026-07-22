# Cost-guardrails module

Owns the 1-unit monthly compartment budget and two email rules: one for actual
spend and one for forecast spend, both at 0.01. OCI interprets these values in
the tenancy's billing currency. The recipient comes from the existing OCI
operator user instead of a value committed to Git.

Budgets warn; they do not stop resources or reverse a charge. The Terraform root
therefore also rejects larger compute and storage settings.
