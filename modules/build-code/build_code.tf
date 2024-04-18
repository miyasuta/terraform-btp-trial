terraform {
  required_providers {
    btp = {
      source  = "sap/btp"
      version = "~> 1.2.0"
    }
  }
}

# ------------------------------------------------------------------------------------------------------
# Entitle subaccount for usage of SAP Build Work Zone, standard edition
# ------------------------------------------------------------------------------------------------------
# resource "btp_subaccount_entitlement" "build_code" {
#   subaccount_id = var.subaccount_id
#   service_name  = "build-code"
#   plan_name     = "free"
# }

resource "btp_subaccount_subscription" "build_code" {
  subaccount_id = var.subaccount_id
  app_name      = "build-code"
  plan_name     = "free"
  # depends_on    = [btp_subaccount_entitlement.build_code]
}

# Assign users to Role Collection: Automation Pilot Administrator
resource "btp_subaccount_role_collection_assignment" "build_code_admin" {
  for_each             = toset(var.admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "Build Code Administrator"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.build_code]
}

resource "btp_subaccount_role_collection_assignment" "build_code_developer" {
  for_each             = toset(var.admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "Build Code Developer"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.build_code]
}