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