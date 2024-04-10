terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    rafay = {
      source  = "registry.terraform.io/RafaySystems/rafay"
      version = ">=0.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.14"
}

provider "azurerm" {
  features {}

  skip_provider_registration = true

  subscription_id = "<Subscription-ID>"
  client_id       = "<Client-ID>"
  client_secret   = "<Client-Secret>"
  tenant_id       = "<Tenant-ID>"
}
