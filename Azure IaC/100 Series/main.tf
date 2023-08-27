#Block 1 always mandatory define the provider.
#Logic Tf core (RPC->) Azure provider (golang->) AzureRM client lib (HTTPS->) Azure cloud
terraform {
  required_version = ">= 0.12" #Greater than or equal to 0.12
  required_providers {
    azurerm = {
        version = "~> 2.32.0" #use the exact version only but allow patches like 2.36.1
        source = "hashicorp/azurerm"
    }
  } 
}
provider "azurerm" {
    features {}
    skip_provider_registration = true
}
#Start of variable declaration block
variable rg_name {
    type = string
    description = "Name of the resource group"
}
variable location {
    type = string
    description = "Location of the resource"
    default = "West US"
}
variable storage_name {
    type = string
    description = "Storage account name"
}
#End of variable declaration block
resource "azurerm_storage_account" "sa" {
    name = var.storage_name
    resource_group_name = var.rg_name
    location = var.location
    account_tier = "Standard"
    account_replication_type = "LRS"
    tags = {
    type = "test"
    }
}

output "storage_account_details" {
    value = azurerm_storage_account.sa.name
}