terraform {
  required_providers {
    btp = {
      source  = "sap/btp"
      version = "~>1.8.0"
    }
  }
}

# ------------------------------------------------------------------------------------------------------
# Entitle subaccount for usage of Cloud Identity Services
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_entitlement" "cloud_identity_services" {
  subaccount_id = var.subaccount_id
  service_name = "sap-identity-services-onboarding"
  plan_name = "default"
}

resource "btp_subaccount_subscription" "cloud_identity_services" {
  subaccount_id = var.subaccount_id
  app_name      = "sap-identity-services-onboarding"
  plan_name     = "default"
  depends_on    = [btp_subaccount_entitlement.cloud_identity_services]
}

output "cloud_identity_services_host" {
  description = "Extracted host from the cloud identity services URL"
  value       = regex("https://([^/]+)/admin", btp_subaccount_subscription.cloud_identity_services.subscription_url)[0]
}

locals {
  cloud_identity_services_host = regex("https://([^/]+)/admin", btp_subaccount_subscription.cloud_identity_services.subscription_url)[0]
}
# ------------------------------------------------------------------------------------------------------
# Establish Trust with IAS
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_trust_configuration" "trial" {
  subaccount_id     = var.subaccount_id
  identity_provider = local.cloud_identity_services_host
}

