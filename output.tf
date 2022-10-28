output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

output "key_vault_id" {
  value = azurerm_key_vault.kv.id
}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}

output "managed_identity_objectid" {
  value = azurerm_user_assigned_identity.managed_identity.*.principal_id
}

output "managed_identity_clientid" {
  value = azurerm_user_assigned_identity.managed_identity.*.client_id
}
output "managed_identity_id" {
  value = azurerm_user_assigned_identity.managed_identity.*.id
}