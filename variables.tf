variable "globalaccount" {
  type        = string
  description = "The globalaccount subdomain where the sub account shall be created."
}

variable "region" {
  type        = string
  description = "The region where the sub account shall be created in."
  default     = "ap21"

  # Checkout https://github.com/SAP-samples/btp-service-metadata/blob/main/v0/developer/aicore.json for the latest list of regions
  # supported by the AI Core service.
  validation {
    condition     = contains(["eu10-canary", "ap10", "eu10", "eu11", "jp10", "us10", "ap21"], var.region)
    error_message = "Please enter a valid region for the sub account. Checkout https://github.com/SAP-samples/btp-service-metadata/blob/main/v0/developer/aicore.json for regions providing the AI Core service."
  }  
}

variable "subaccount_id" {
  type        = string
  description = "The subaccount id."
}

variable "hc_instance_name" {
  type        = string
  description = "HANA Cloud instance name"
  default = "HC_HDB"
}

variable "hana_system_password" {
  type        = string
  description = "The password of the database 'superuser' DBADMIN."
  sensitive   = true

  # add validation to check if the password is at least 8 characters long
  validation {
    condition     = length(var.hana_system_password) > 7
    error_message = "The hana_system_password must be at least 8 characters long."
  }

  # add validation to check if the password contains at least one upper case
  validation {
    condition     = can(regex("[A-Z]", var.hana_system_password))
    error_message = "The hana_system_password must contain at least one upper case."
  }

  # add validation to check if the password contains at least two lower case characters
  validation {
    condition     = can(regex("[a-z]{2}", var.hana_system_password))
    error_message = "The hana_system_password must contain at least two lower case characters."
  }

  # add validation to check if the password contains at least one numeric character
  validation {
    condition     = can(regex("[0-9]", var.hana_system_password))
    error_message = "The hana_system_password must contain at least one numeric character."
  }

}

variable "integration_suite_app_name" {
  type        = string
  description = "Service plan name for integration suite"  
}

variable "idp_origin" {
  type        = string
  description = "Identity Provider Origin Key"
  default = "sap.custom"
}

variable "ias_group" {
  type        = string
  description = "A group to be mapped to the required role collections"
  default = "Trial_Default"
}