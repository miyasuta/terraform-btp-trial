terraform {
  required_providers {
    btp = {
      source  = "sap/btp"
      version = "~>1.13.0"
    }
  }
}

# ------------------------------------------------------------------------------------------------------
# Entitle subaccount for usage of SAP Build Work Zone, standard edition
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_entitlement" "workzone" {
  subaccount_id = var.subaccount_id
  service_name  = "SAPLaunchpad"
  plan_name     = "standard"
}

resource "btp_subaccount_subscription" "workzone" {
  subaccount_id = var.subaccount_id
  app_name      = "SAPLaunchpad"
  plan_name     = "standard"
  depends_on    = [btp_subaccount_entitlement.workzone]
}

# Assign users to Role Collection: Automation Pilot Administrator
resource "btp_subaccount_role_collection_assignment" "workzone_admin_ias" {
  for_each             = toset(var.admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "Launchpad_Admin"
  origin               = var.idp_origin
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.workzone]
}