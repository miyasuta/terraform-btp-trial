
variable "subaccount_id" {
  type        = string
  description = "The subaccount id."
}

variable "admins" {
  type        = list(string)
  description = "Defines the colleagues who are added to each subaccount as emergency administrators."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.admins : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.admins)
    error_message = "Please enter a valid email address for the admins."
  }

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