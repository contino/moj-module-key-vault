resource "azurerm_key_vault_access_policy" "managed_identity_access_policy" {
  key_vault_id = "${azurerm_key_vault.kv.id}"

  object_id = "${var.managed_identity_object_id}"
  tenant_id = "${var.tenant_id}"

  key_permissions = [
    "get",
    "list",
  ]

  certificate_permissions = [
    "get",
    "list",
  ]

  secret_permissions = [
    "get",
    "list",
  ]

  count = "${var.managed_identity_object_id != "" ? 1 : 0}"
}
