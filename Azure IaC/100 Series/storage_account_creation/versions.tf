terraform {
  required_version = ">= 0.12" #Greater than or equal to 0.12
  required_providers {
    azurerm = {
        version = "~> 2.32.0" #use the exact version only but allow patches like 2.36.1
        source = "hashicorp/azurerm"
    }
  } 
}