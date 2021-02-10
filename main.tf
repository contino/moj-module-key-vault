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

  tags = var.common_tags
}

resource "azurerm_key_vault_access_policy" "creator_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id

  object_id = data.azurerm_client_config.current.object_id
  tenant_id = data.azurerm_client_config.current.tenant_id

  certificate_permissions = [
    "create",
    "delete",
    "deleteissuers",
    "get",
    "getissuers",
    "import",
    "list",
    "listissuers",
    "setissuers",
    "update",
    "managecontacts",
    "manageissuers",
  ]

  key_permissions = [
    "create",
    "list",
    "get",
    "delete",
    "update",
    "import",
    "backup",
    "restore",
  ]

  secret_permissions = [
    "set",
    "list",
    "get",
    "delete",
    "recover",
  ]
}
