terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~>1.26.0"
    }
  }
}

provider "btp" {
  globalaccount = var.globalaccount
}