terraform {
    required_version = ">= 0.12.0"
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

variable "rg" {
    type = string
    description = "Resource group name"
}

variable "location" {
    type = string
    description = "Location of the storage account"
    validation {
        condition = contains(["East US", "West US"], var.location)
        error_message = "Incorrect location mentioned"
    }
}

variable "sg_name"{
    type = string
    description = "Storage account name"
}

resource "azurerm_storage_account" sa {
    name = var.sg_name
    resource_group_name = var.rg
    location = var.location
    account_tier = "standard"
    account_replication_type = "LRS"
    tags = {"createdFrom" : "Terraform"}    
}

output "storage_account_details" {
    value = azurerm_storage_account.sa.name
}

