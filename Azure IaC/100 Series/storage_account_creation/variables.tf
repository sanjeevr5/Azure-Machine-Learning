variable rg_name {
    type = string
    description = "Name of the resource group"
}
variable location {
    type = string
    description = "Location of the resource"
    default = "West US"
}
variable storage_name {
    type = string
    description = "Storage account name"
}