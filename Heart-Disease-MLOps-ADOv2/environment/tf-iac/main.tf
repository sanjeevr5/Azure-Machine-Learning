terraform {
    backend "azurerm" {
        resource_group_name  = "${var.resource_group}"
        storage_account_name = "heartdiseasestatestor"
        container_name       = "tfstate-cont"
        key                  = "prod.terraform.tfstate"
    }
    required_providers {
        azurerm = {
            version = ">= 2.32.0"
            source = "hashicorp/azurerm"
        }
    }
}

provider "azurerm" {
    features {}
    skip_provider_registration = true
}

variable BASE_NAME {
    type = string
}
variable RG{
    type = string
}
variable WS_NAME{
    type = string
}

data "azurerm_resource_group" "rg"{
    name = var.RG
}

data "azurerm_client_config" "config"{} #Access the current RM's config

#Creating Storage Account
resource "azurerm_storage_account" "sa" {
    name = "${var.BASE_NAME}mlops"
    location = data.azurerm_resource_group.rg.location
    resource_group_name      = data.azurerm_resource_group.rg.name
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

#Keyvault
resource "azurerm_key_vault" "kv" {
  name                = "${var.BASE_NAME}-AML-KV"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.config.tenant_id
  sku_name            = "standard"
}

# Application Insights
resource "azurerm_application_insights" "app_ins" {
  name                = "${var.BASE_NAME}-AML-AI"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  application_type    = "web"
}

# Container registry for AML Service
resource "azurerm_container_registry" "acr" {
  name                     = "${var.BASE_NAME}amlcr"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  sku                      = "Basic"
  admin_enabled            = true
}

resource "azurerm_machine_learning_workspace" "amlws" {
  name                    = var.WS_NAME
  location                = data.azurerm_resource_group.rg.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  application_insights_id = azurerm_application_insights.app_ins.id
  key_vault_id            = azurerm_key_vault.kv.id
  storage_account_id      = azurerm_storage_account.sa.id
  container_registry_id   = azurerm_container_registry.acr.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_log_analytics_workspace" "alws"{
  name = "${var.BASE_NAME}logws"
  location = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku = "PerGB2018"
  retention_in_days = 30
}