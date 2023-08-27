#If the terraform files are executed locally then the state file consists of the current state of the environment and is stored locally
#What if multiple users are using the same file to edit but the state of the environment is locally stored?
#This can result in unexpected/unwanted results
#Hence, it is better to store the state file in some remote environment to make sure everyone is in sync
# During init use 
#terraform init -backend-config="<SAS-TOKEN>" [or] terraform init -backend-config="backend-config.tfvars"
terraform {
    backend "azurerm" {
        resource_group_name  = var.resource_group_name
        storage_account_name = var.storage_account_name
        container_name       = var.container_name
        key                  = var.key
        sas_token            = var.sas_token
    }
    required_providers {
        azurerm = {
            version = "~> 2.32.0"
            source = "hashicorp/azurerm"
        }
    }
}

variable resource_group_name {type = string}
variable storage_account_name {type = string}
variable container_name {type = string}
variable key {type = string}
variable sas_token {type = string}

provider "azurerm" {
    features {}
    skip_provider_registration = true
}



resource "azurerm_storage_account" "sa" {
    name = "jasldkajsd"
    resource_group_name = "1-67c44ab5-playground-sandbox"
    location = "East US"
    account_tier = "Standard"
    account_replication_type = "LRS"
    tags = {
    type = "test"
    }
}

output sa {
    value = azurerm_storage_account.sa.name
}