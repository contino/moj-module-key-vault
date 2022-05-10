resource "azurerm_role_assignment" "github_runner" {
  for_each = var.role_assignments

  scope                = azurerm_key_vault.kv.id
  role_definition_name = each.value.role_name
  principal_id         = each.value.object_id
}