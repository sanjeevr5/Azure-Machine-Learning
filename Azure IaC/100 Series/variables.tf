#Terraform structure
#Terraform execution 
#1. Upload the .tf to the required execution folder
#2. terraform init
#3. terraform validate
#4. terraform refresh - to get the current state of the cloud infra
#5. terraform plan - This is not mandatory but will help to understand before execution
#6. terraform apply - with parameters supplied will execute the code
#Terraform flow
#Logic Tf core (RPC->) Azure provider (golang->) AzureRM client lib (HTTPS->) Azure cloud

terraform {
    required_version = ">=0.13" #This is terraform's version
    #For every terraform we require a provider
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
    #Insert SPA details here!
}

variable str {
    type = string
    description = "This is a string variable"
    default = "default-string"
    validation {
        condition = (length(var.var_name) <= 10 && length(var.var_name) >= 2)
        #Condition can also have regex based expression check
        error_msg = "The length should be between 2 and 10 characters."
        #The error msg should start with a capital letter and end with a '?' or '.'
    }
    sensitive = false #boolean variable
}

variable lst {
    type = list(string) #(or) list(any)
    default = ["Apple", "Carrot"] 
}

variable mp {
    type = list(map(string))
    default = [
        {
            name = "Sanjeev"
            age = "27"
        }
    ]
}

variable complexDType {
    type = list(object({#no need to explicitly write map
        name = string
        age = number
    })) #(or) list(map(any))
    default = [
        {
            name = "Sanjeev"
            age = 27
        }
    ]
}

variable tup {
    type = tuple([string, number])
    default = ["hi", 2] #starting access index is 0
}

variable sett {
    type = set(string)
    default = ["one", "two"] #It contains only unique set of values
}
output lst{
    value = var.lst #(or) var.lst[1] will print Apple
}

output mp {
    value = var.mp["name"]
}

output sett {
    value = tolist(var.sett)[0]
}