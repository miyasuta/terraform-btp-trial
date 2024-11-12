# ------------------------------------------------------------------------------------------------------
# Establish Trust with IAS
# ------------------------------------------------------------------------------------------------------
# Execute the following command first, if trust has already been established
# terraform import btp_subaccount_trust_configuration.trial <subaccoint_id>,sap.custom
resource "btp_subaccount_trust_configuration" "trial" {
  subaccount_id     = var.subaccount_id
  identity_provider = var.identity_provider
  count = var.use_ias_for_login ? 1 : 0
}

# ------------------------------------------------------------------------------------------------------
# Assign role collections
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_role_collection_assignment" "bas" {
  subaccount_id        = var.subaccount_id
  role_collection_name = "Business_Application_Studio_Developer"
  origin               = var.idp_origin
  group_name           = var.ias_group
  count = var.use_ias_for_login ? 1 : 0
}

# ------------------------------------------------------------------------------------------------------
# Set up HANA Cloud
# ------------------------------------------------------------------------------------------------------
module "hana_cloud_setup" {
  source = "./modules/hana-cloud"

  subaccount_id        = var.subaccount_id
  hc_instance_name     = var.hc_instance_name
  hana_system_password = var.hana_system_password
  admins               = var.admins
  idp_origin           = var.idp_origin
  ias_group            = var.ias_group
  use_ias_for_login    = var.use_ias_for_login 
}

# ------------------------------------------------------------------------------------------------------
# Set up Work Zone
# ------------------------------------------------------------------------------------------------------
module "workzone_setup" {
  source = "./modules/workzone"

  subaccount_id        = var.subaccount_id
  admins               = var.admins
  idp_origin           = var.idp_origin
  ias_group            = var.ias_group
  use_ias_for_login    = var.use_ias_for_login 
}

# ------------------------------------------------------------------------------------------------------
# Set up Integratio Suite
# ------------------------------------------------------------------------------------------------------
module "integration_suite_setup" {
  source = "./modules/integration-suite"

  subaccount_id        = var.subaccount_id
  admins               = var.admins
  integration_suite_app_name =  var.integration_suite_app_name
  idp_origin           = var.idp_origin
  ias_group            = var.ias_group
  use_ias_for_login    = var.use_ias_for_login 
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
  identity_provider = var.identity_provider
  count = var.use_ias_for_login ? 1 : 0
}

module "automation_pilot_setup" {
  source = "./modules/automation-pilot"

  subaccount_id        = btp_subaccount.automation_pilot.id
  admins               = var.admins
  idp_origin           = var.idp_origin
  ias_group            = var.ias_group
  use_ias_for_login    = var.use_ias_for_login 
}