locals {
  managed_identity_list      = toset(compact(concat(var.managed_identity_object_ids, [var.managed_identity_object_id])))
  managed_identity_name_list = var.env == "aat" ? toset(compact(concat([var.product_name], [var.product_names]))) : {}
}

resource "azurerm_user_assigned_identity" "managed_identity" {

  resource_group_name = "managed-identities-${var.env}-rg"
  location            = var.location

  name = "${var.product}-${var.env}-mi"

  tags  = var.common_tags
  count = var.create_managed_identity ? 1 : 0
}

resource "azurerm_key_vault_access_policy" "managed_identity_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  object_id    = each.value
  tenant_id    = data.azurerm_client_config.current.tenant_id

  key_permissions = [
    "Get",
    "List",
  ]

  certificate_permissions = [
    "Get",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]

  for_each = local.managed_identity_list
}

resource "azurerm_key_vault_access_policy" "managed_identity_names_access_policy" {
  # count = var.env == "aat" ? 1 : 0

  key_vault_id = azurerm_key_vault.kv.id
  object_id    = each.value
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = [
    "Get",
    "List"
  ]

  for_each = ${local.managed_identity_name_list}-aat-mi
}


resource "azurerm_key_vault_access_policy" "implicit_managed_identity_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id

  object_id = azurerm_user_assigned_identity.managed_identity[0].principal_id
  tenant_id = data.azurerm_client_config.current.tenant_id

  key_permissions = [
    "Get",
    "List",
  ]

  certificate_permissions = [
    "Get",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]

  count = var.create_managed_identity ? 1 : 0
}
