terraform {
  required_providers {
    btp = {
      source  = "sap/btp"
      version = "~>1.8.0"
    }
  }
}

# ------------------------------------------------------------------------------------------------------
# Entitle subaccount for usage of Automation Pilot
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_entitlement" "automation_pilot" {
  subaccount_id = var.subaccount_id
  service_name  = "automationpilot"
  plan_name     = "free"
}

resource "btp_subaccount_subscription" "automation_pilot" {
  subaccount_id = var.subaccount_id
  app_name      = "automationpilot"
  plan_name     = "free"
  depends_on    = [btp_subaccount_entitlement.automation_pilot]
}

# Assign users to Role Collection: Automation Pilot Administrator
resource "btp_subaccount_role_collection_assignment" "automation_pilot_admin" {
  for_each             = toset(var.admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "AutomationPilot_Admin"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.automation_pilot]
}