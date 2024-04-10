terraform {
  required_providers {
    rafay = {
      version = ">= 0.1"
      source = "registry.terraform.io/RafaySystems/rafay"
    }
  }
}

provider "rafay" {
  provider_config_file = "/Users/Fabian.B/Downloads/rafay_configs/Rafay-Demos-fabian@rafay.co.json"
}
