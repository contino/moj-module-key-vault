locals {
  managed_identity_list = "${compact(concat(var.managed_identity_object_ids, list(var.managed_identity_object_id)))}"
}
resource "azurerm_key_vault_access_policy" "managed_identity_access_policy" {
  key_vault_id = "${azurerm_key_vault.kv.id}"

  object_id = "${local.managed_identity_list[count.index]}"
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

  count = "${length(local.managed_identity_list)}"
}
