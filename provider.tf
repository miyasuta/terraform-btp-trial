terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~>1.20.1"
    }
  }
}

provider "btp" {
  globalaccount = var.globalaccount
}