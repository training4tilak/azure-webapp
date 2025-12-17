# ───────────────────────────────────────────────────────────── #
# Terraform Configuration Block                                 #
#                                                               #
# Defines required providers and minimum Terraform CLI version  #
# for consistent deployments across environments.               #
# ───────────────────────────────────────────────────────────── #

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
  subscription_id = var.networkingSub
  alias           = "networkingsub"
}
