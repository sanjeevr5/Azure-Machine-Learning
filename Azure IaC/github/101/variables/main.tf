terraform {
    required_version = ">= 0.12"
    required_providers {
        azurerm = {
            version = "~> 2.32.0"
            source = "hashicorp/azurerm"
        }
    }
}

provider azurerm {
    features = {}
    skip_provider_registration = true
}

variable "name" {
    type = string
    nullable = false
    description = "Name of the applicant"
}

variable "age" {
    type = number
    nullable = false
    description = "Age of the applicant"
    validation {
        condition = (var.age <= 50) && (var.age >=18)
        error_message = "You can apply only if your age is between 18 and 50"
    }
}

variable "location" {
    type = map
    description = "Location in {city:country} format"
}

variable "core_skill" {
    type = string
    description = "Core skill of the candidate"
}

variable "general_skills" {
    type = list(object({
        domain = string
        skills = list(string)
    }))
    description = "Skills listed"
}

output "name" {
    value =  var.name
}

output "age" {
    value =  var.age
}

output "loc" {
    value =  {for city, country in var.location : "City ${city}" => "Country ${country}"}
}

output "data_scientist" {
    value = var.core_skill == "Data Scientist" ? true : false
}

output "skills"{
    value = {for value in var.general_skills : "Domain : ${value.domain}" => "skills : ${list(var.skills)}"}
}

#terraform apply -var name="sanjeev" -var age=20 -var=location='{"ab" : "cd"}' -var=general_skills='[{domain = "cloud", skills = ["azure", "aws"]}, {domain = "code", skills = ["Python", "C"]}]'