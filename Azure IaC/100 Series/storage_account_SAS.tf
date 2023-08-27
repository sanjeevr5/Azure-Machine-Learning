terraform {
  required_version = ">=0.12.0"
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

variable rg {
  type = string
  description = "Resource group name"
}

variable storage_name {
  type = string
  description = "Storage account name"
}

variable location {
  type = string
  description = "Storage account name"
  default = "East US"
}

resource "azurerm_storage_account" "remotestatestorage" {
  name                     = var.storage_name
  resource_group_name      = var.rg
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = {
    environment = "test"
  }
}

resource "azurerm_storage_container" "remotestate-container" {
  name                  = "statefiles"
  storage_account_name  = azurerm_storage_account.remotestatestorage.name
  container_access_type = "private"
}

#Resources are meant to be created, updated and deleted
#data sources are meant to read the current state of the resources

data "azurerm_storage_account_blob_container_sas" "container-sas" {
  connection_string = azurerm_storage_account.remotestatestorage.primary_connection_string
  container_name    = azurerm_storage_container.remotestate-container.name
  https_only        = true
  start  = "2023-02-07"
  expiry = "2023-02-08"
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

