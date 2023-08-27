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
    skip_provider_registration = true
}

variable rg_name { type = string}
variable location { type = string}
variable stg_acc_name { type = string}
variable n_storage_accs { type = number}

resource "azurerm_storage_account" "stg_acc"{
    count = var.n_storage_accs #count = length(var.stg_acc_name) if type = list
    name = "${var.stg_acc_name}${count.index}"
    location = var.location
    resource_group_name = var.rg_name
    account_replication_type = "LRS"
    account_tier             = "Standard"
    account_kind             = "StorageV2"

}

output storage_account_ids {
    value = azurerm_storage_account.stg_acc[*].id
}