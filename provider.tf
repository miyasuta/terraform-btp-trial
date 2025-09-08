terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~>1.15.1"
    }
  }
}

provider "btp" {
  globalaccount = var.globalaccount
}