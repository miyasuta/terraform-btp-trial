# ------------------------------------------------------------------------------------------------------
# Subscribe to Cloud Identity Services and establish trust with trial subaccount
# ------------------------------------------------------------------------------------------------------
module "cloud_identity_services" {
  source = "./modules/cloud-identity-services"

  subaccount_id = var.subaccount_id
}

locals {
  cloud_identity_services_host = module.cloud_identity_services.cloud_identity_services_host
}

# ------------------------------------------------------------------------------------------------------
# Assign role collection for BAS
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_role_collection_assignment" "bas" {
  for_each             = toset(var.admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "Business_Application_Studio_Developer"
  origin               = var.idp_origin
  user_name            = each.value
  depends_on           = [ module.cloud_identity_services ]
}

# ------------------------------------------------------------------------------------------------------
# Set up HANA Cloud
# ------------------------------------------------------------------------------------------------------
module "hana_cloud_setup" {
  source = "./modules/hana-cloud"

  subaccount_id        = var.subaccount_id
  hc_instance_name     = var.hc_instance_name
  hana_system_password = var.hana_system_password
  idp_origin           = var.idp_origin
  admins               = var.admins
  depends_on           = [ module.cloud_identity_services ]
}

# ------------------------------------------------------------------------------------------------------
# Set up Work Zone
# ------------------------------------------------------------------------------------------------------
module "workzone_setup" {
  source = "./modules/workzone"

  subaccount_id        = var.subaccount_id
  idp_origin           = var.idp_origin
  admins               = var.admins
  depends_on           = [ module.cloud_identity_services ]
}

# ------------------------------------------------------------------------------------------------------
# Set up Integratio Suite
# ------------------------------------------------------------------------------------------------------
module "integration_suite_setup" {
  source = "./modules/integration-suite"

  subaccount_id        = var.subaccount_id
  integration_suite_app_name =  var.integration_suite_app_name
  idp_origin           = var.idp_origin
  admins               = var.admins
  depends_on           = [ module.cloud_identity_services ]
}

# ------------------------------------------------------------------------------------------------------
# Set up Automation Pilot
# ------------------------------------------------------------------------------------------------------
resource "random_id" "subaccount_domain_suffix" {
  byte_length = 12
}

resource "btp_subaccount" "automation_pilot" {
  name      = "automationPilot"
  subdomain = join("-", ["automation-pilot", random_id.subaccount_domain_suffix.hex])
  region    = lower(var.region)
}

resource "btp_subaccount_trust_configuration" "automation_pilot" {
  subaccount_id     = btp_subaccount.automation_pilot.id
  identity_provider = local.cloud_identity_services_host
}

module "automation_pilot_setup" {
  source = "./modules/automation-pilot"

  subaccount_id        = btp_subaccount.automation_pilot.id
  idp_origin           = var.idp_origin
  admins               = var.admins
  depends_on           = [ btp_subaccount_trust_configuration.automation_pilot ]
}