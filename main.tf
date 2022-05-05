locals {
  vaultName = var.name == "" ? format("%s-%s", var.product, var.env) : var.name
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                = local.vaultName
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name  = var.sku
  tenant_id = data.azurerm_client_config.current.tenant_id

  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  soft_delete_retention_days      = 90

  network_acls {
    bypass         = "AzureServices"
    default_action = var.network_acls_default_action # Default is "Deny"
    ip_rules       = var.network_acls_allowed_ip_ranges
    # virtual_network_subnet_ids = []
  }

  tags = var.common_tags
}

resource "azurerm_key_vault_access_policy" "creator_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id

  object_id = var.object_id
  tenant_id = data.azurerm_client_config.current.tenant_id

  certificate_permissions = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "SetIssuers",
    "Update",
    "ManageContacts",
    "ManageIssuers",
  ]

  key_permissions = [
    "Create",
    "List",
    "Get",
    "Delete",
    "Update",
    "Import",
    "Backup",
    "Restore",
  ]

  secret_permissions = [
    "Set",
    "List",
    "Get",
    "Delete",
    "Recover",
    "Purge",
  ]
}
