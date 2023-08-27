terraform{
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

variable storage_accs {
    type = map
}

resource "azurerm_storage_account" "stg_acc" {
    for_each = var.storage_accs
    name = each.key
    location = each.value
    resource_group_name = "1-cc3f8e78-playground-sandbox"
    account_replication_type = "LRS"
    account_tier             = "Standard"
    account_kind             = "StorageV2"
    min_tls_version          = "TLS1_2"
    enable_https_traffic_only = true
}

output "vals" {
    value = values(azurerm_storage_account.stg_acc)[*].name
}