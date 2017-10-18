output "key_vault_ui" {
  value = "${azurerm_key_vault.kv.vault_uri}"
}
