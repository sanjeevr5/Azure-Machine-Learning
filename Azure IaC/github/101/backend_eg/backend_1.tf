terraform{
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

variable "state_storage_name"{
    type = string
    description = "Storage account to store the state files"
    nullable = false
}

variable "state_location" {
    type = string
    description = "Location of the state file"
}

variable "rg_name" {
    type = string
    description = "RG name"
}

#Creating a storage account for storing the state

resource "azurerm_storage_account" "remotestatestorage" {
  name                     = var.state_storage_name
  resource_group_name      = var.rg_name
  location                 = var.state_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    "createdFrom" = "Terraform"
  }
}

#Creating a container in which the state files will be stored

resource "azurerm_storage_container" "remotestate-container" {
  name                  = "statefiles"
  storage_account_name  = azurerm_storage_account.remotestatestorage.name
  container_access_type = "private"
}

#Resources are meant to be created, updated and deleted
#data sources are meant to read the current state of the resources

#We need an SAS token to make modifications to the container
data "azurerm_storage_account_blob_container_sas" "container-sas" {
  connection_string = azurerm_storage_account.remotestatestorage.primary_connection_string
  container_name    = azurerm_storage_container.remotestate-container.name
  https_only        = true
  start  = "2023-02-05"
  expiry = "2023-03-08"
  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
  cache_control       = "max-age=5"
  content_disposition = "inline"
  content_encoding    = "deflate"
  content_language    = "en-US"
  content_type        = "application/json"
}

output "sas_container_query_string" {
  value = data.azurerm_storage_account_blob_container_sas.container-sas.sas
  sensitive = true
}
