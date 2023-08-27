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

variable planName {type = string}
variable appName {type = string}
variable location {type = string}
variable rg_name {type = string}
variable tags {type = map}
variable planKind {type = string}
variable planSKU { type = map}
variable conStrings {
    type = list(object({
        name = string
        type = string
        value = string
    }))
}

locals {
    default_tags = {
        "env" : "dev"
    }
    app_size = "B1"
}

resource "azurerm_app_service_plan" "app_service_plan" {
    name = var.planName
    location = var.location
    resource_group_name = var.rg_name
    kind = var.planKind
    reserved  = var.planKind == "Linux" ? true : false #If condition
    sku {
        capacity = lookup(var.planSKU, "capacity", null)
        size     = lookup(var.planSKU, "size", null)
        tier     = lookup(var.planSKU, "tier", null)
    }
    tags = local.default_tags#merge(local.default_tags, var.custom_tags)
}

resource "azurerm_app_service" "app_service" {
name                = var.appName
location            = var.location
resource_group_name = var.rg_name
app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
dynamic "connection_string" {
    for_each = var.conStrings
    content {
    name  = lookup(connection_string.value, "name", null)
    type  = lookup(connection_string.value, "type", null)
    value = lookup(connection_string.value, "value", null)
    }
}
https_only = true
}

output app_service_plan_identifier {
    value = azurerm_app_service_plan.app_service_plan.id
}