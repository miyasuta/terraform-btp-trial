terraform {
  required_providers {
    btp = {
      source  = "sap/btp"
      version = "~>1.20.1"
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

# Assign users to Role Collection: Integration_Provisioner
resource "btp_subaccount_role_collection_assignment" "integration_suite_provisioner_ias" {
  for_each             = toset(var.admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "Integration_Provisioner"
  origin               = var.idp_origin
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.integration_suite]

  # Trial の Integration Suite サブスクリプションは期限切れで自動削除されることがあり、
  # その際にロールコレクション(=本割当)も消える。Subscription が再作成されたら
  # 割当も連動して作り直す。
  lifecycle {
    replace_triggered_by = [btp_subaccount_subscription.integration_suite]
  }
}