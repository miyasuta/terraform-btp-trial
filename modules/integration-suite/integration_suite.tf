terraform {
  required_providers {
    btp = {
      source  = "sap/btp"
      version = "~>1.6.0"
    }
  }
}

# ------------------------------------------------------------------------------------------------------
# Entitle subaccount for usage of Integration Suite
# ------------------------------------------------------------------------------------------------------
# comment out due to error
# resource "btp_subaccount_entitlement" "integration_suite" {
#   subaccount_id = var.subaccount_id
#   service_name  = "integrationsuite-trial"
#   plan_name     = "trial"
# }

resource "btp_subaccount_subscription" "integration_suite" {
  subaccount_id = var.subaccount_id
  app_name      = var.integration_suite_app_name
  plan_name     = "trial"
  # depends_on    = [btp_subaccount_entitlement.integration_suite]
}

# Assign users to Role Collection: Automation Pilot Administrator
resource "btp_subaccount_role_collection_assignment" "integration_suite_provisioner" {
  for_each             = toset(var.admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "Integration_Provisioner"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.integration_suite]
}