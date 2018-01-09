variable "product" {
    type                        = "string"
    description                 = "(Required) The name of your application"
}

variable "env" {
    type                        = "string"
    description                 = "(Required)"
}

variable "tenant_id" {
    type                        = "string"
    description                 = "(Required) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault."
}
variable "object_id" {
    type                        = "string"
    description                 = "(Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies."
}

variable "vault_name_suffix" {
    type                        = "string"
    default                     = "vault"
    description                 = "Please don't override this default unless required to do so as this will not be complaint with naming convention."
}

variable "location" {
    type                        = "string"
    default                     = "UK South"
    description                 = "The name of the Azure region to deploy your vault to. Please use the default by not passing this parameter unless instructed otherwise."
}
