resource "azurerm_role_assignment" "this" {
  for_each = var.additional_role_assignments

  scope                = azurerm_key_vault.kv.id
  role_definition_name = each.value.role_name
  principal_id         = each.value.object_id
}