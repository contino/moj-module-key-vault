variable "name" {
  type        = "string"
  default     = ""
  description = "The vault name (at most 24 characters - Azure Key Vault name limit). If not provided then product-env pair will be used as a default."
}

variable "product" {
  type        = "string"
  description = "(Required) The name of your application"
}

variable "env" {
  type        = "string"
  description = "(Required)"
}

variable "resource_group_name" {
  type        = "string"
  description = "(Required) The resource group you wish to put your Vault in. This has to exist already."
}

variable "tenant_id" {
  type        = "string"
  description = "(Required) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault."
}

variable "object_id" {
  type        = "string"
  description = "(Required) The Azure AD object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies."
}

variable "vault_name_suffix" {
  type        = "string"
  default     = "vault"
  description = "Please don't override this default unless required to do so as this will not be complaint with naming convention."
}

variable "location" {
  type        = "string"
  default     = "UK South"
  description = "The name of the Azure region to deploy your vault to. Please use the default by not passing this parameter unless instructed otherwise."
}

variable "product_group_object_id" {
  description = "The AD group of users that should have access to add secrets to the key vault, see the README on where to find this"
}

variable "managed_identity_object_id" {
  default = ""
  description = "the object id of the managed identity - can be retrieved with az identity show --name <identity-name>-sandbox-mi -g managed-identities-<env>-rg --subscription DCD-CFTAPPS-<env> --query principalId -o tsv"
}

variable "common_tags" {
  type = "map"
}

variable "sku" {
  default     = "standard"
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium."
}
