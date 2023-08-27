#If the terraform files are executed locally then the state file consists of the current state of the environment and is stored locally
#What if multiple users are using the same file to edit but the state of the environment is locally stored?
#This can result in unexpected/unwanted results
#Hence, it is better to store the state file in some remote environment to make sure everyone is in sync
# During init use 
#terraform init -backend-config="<SAS-TOKEN>"


terraform {
    backend "azurerm" {
        resource_group_name  = "1-e09cbf19-playground-sandbox"
        storage_account_name = "sadaskld3"
        container_name       = "statefiles"
        key                  = "prod.terraform.tfstate"
    }
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

resource "azurerm_storage_account" "sa" {
    name = "jasldkajsd"
    resource_group_name = "1-e09cbf19-playground-sandbox"
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