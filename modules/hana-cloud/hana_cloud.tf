terraform {
  required_providers {
    btp = {
      source  = "sap/btp"
      version = "~>1.3.0"
    }
  }
}
# ------------------------------------------------------------------------------------------------------
# Entitle subaccount for usage of SAP HANA Cloud tools
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_entitlement" "hana_cloud_tools" {
  subaccount_id = var.subaccount_id
  service_name  = "hana-cloud-tools-trial"
  plan_name     = "tools"
}

resource "btp_subaccount_subscription" "hana_cloud_tools" {
  subaccount_id = var.subaccount_id
  app_name      = "hana-cloud-tools-trial"
  plan_name     = "tools"
  depends_on    = [btp_subaccount_entitlement.hana_cloud_tools]
}

# Assign users to Role Collection: SAP HANA Cloud Administrator
resource "btp_subaccount_role_collection_assignment" "hana_cloud_admin" {
  for_each             = toset(var.admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "SAP HANA Cloud Administrator"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.hana_cloud_tools]
}

# ------------------------------------------------------------------------------------------------------
# Entitle subaccount for usage of SAP HANA Cloud
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_entitlement" "hana_cloud" {
  subaccount_id = var.subaccount_id
  service_name  = "hana-cloud-trial"
  plan_name     = "hana"
}

# Get plan for SAP HANA Cloud
data "btp_subaccount_service_plan" "hana_cloud" {
  subaccount_id = var.subaccount_id
  offering_name = "hana-cloud-trial"
  name          = "hana"
  depends_on    = [btp_subaccount_entitlement.hana_cloud]
}

resource "btp_subaccount_service_instance" "hana_cloud" {
  subaccount_id  = var.subaccount_id
  serviceplan_id = data.btp_subaccount_service_plan.hana_cloud.id
  name           = "hanatrial"
  depends_on     = [btp_subaccount_entitlement.hana_cloud]
  parameters = jsonencode(
    { 
      "data" : {
        "memory" : 16,
        "edition" : "cloud",
        "systempassword" : "${var.hana_system_password}",
        "storage" : 80,
        "vcpu" : 1,
        "whitelistIPs" : ["0.0.0.0/0"] #allow access from any IP address
      }
  })

  timeouts = {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}

# Create service binding to SAP HANA Cloud service 
resource "btp_subaccount_service_binding" "hana_cloud" {
  subaccount_id       = var.subaccount_id
  service_instance_id = btp_subaccount_service_instance.hana_cloud.id
  name                = "hana-cloud-key"
}

# ------------------------------------------------------------------------------------------------------
# Create instance of service manager
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_entitlement" "service_manager" {
  subaccount_id = var.subaccount_id
  service_name  = "service-manager"
  plan_name     = "subaccount-admin"
}

# Get plan for service manager
data "btp_subaccount_service_plan" "service_manager" {
  subaccount_id = var.subaccount_id
  offering_name = "service-manager"
  name          = "subaccount-admin"
  depends_on    = [btp_subaccount_entitlement.service_manager]
}

resource "btp_subaccount_service_instance" "service_manager" {
  subaccount_id  = var.subaccount_id
  serviceplan_id = data.btp_subaccount_service_plan.service_manager.id
  name           = "service-manager"
  depends_on     = [btp_subaccount_entitlement.service_manager]
}

resource "btp_subaccount_service_binding" "service_manager" {
  subaccount_id       = var.subaccount_id
  service_instance_id = btp_subaccount_service_instance.service_manager.id
  name                = "service-manager-key"
}