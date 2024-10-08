# ------------------------------------------------------------------------------------------------------
# Set up HANA Cloud
# ------------------------------------------------------------------------------------------------------
module "hana_cloud_setup" {
  source = "./modules/hana-cloud"

  subaccount_id        = var.subaccount_id
  hc_instance_name     = var.hc_instance_name
  hana_system_password = var.hana_system_password
  admins               = var.admins
}

# ------------------------------------------------------------------------------------------------------
# Set up Work Zone
# ------------------------------------------------------------------------------------------------------
module "workzone_setup" {
  source = "./modules/workzone"

  subaccount_id        = var.subaccount_id
  admins               = var.admins
}

# ------------------------------------------------------------------------------------------------------
# Set up Integratio Suite
# ------------------------------------------------------------------------------------------------------
module "integration_suite_setup" {
  source = "./modules/integration-suite"

  subaccount_id        = var.subaccount_id
  admins               = var.admins
  integration_suite_app_name =  var.integration_suite_app_name
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

module "automation_pilot_setup" {
  source = "./modules/automation-pilot"

  subaccount_id        = btp_subaccount.automation_pilot.id
  admins               = var.admins
}