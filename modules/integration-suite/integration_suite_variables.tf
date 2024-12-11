variable "subaccount_id" {
  type        = string
  description = "The subaccount id."
}

variable "integration_suite_app_name" {
  type        = string
  description = "Service plan name for integration suite"  
}

variable "idp_origin" {
  type        = string
  description = "Identity Provider Origin Key"
}

variable "ias_group" {
  type        = string
  description = "A group to be mapped to the required role collections"
}