terraform {
    required_version = ">= 0.12"
    required_providers {
        azurerm = {
            version = "~> 2.32.0"
            source = "hashicorp/azurerm"
        }
    }
}
provider "azurerm" {
  features {}
}
variable storage_account_info { type=map }

output storage_account_location_eastus {
    value = {for name, location in var.storage_account_info: lower(name) => upper(location)}
}
#(or)
output storage_account_location_eastusx {
    value = [for name, location in var.storage_account_info: lower(name)]
}

#Run command : terraform apply -var storage_account_info='{"name" : "location"}'