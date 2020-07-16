locals {
  managed_identity_list = "${compact(concat(list(var.managed_identity_object_id), var.managed_identity_object_ids))}"
}

  resource "azurerm_user_assigned_identity" "managed_identity" {

  resource_group_name = "managed-identities-${var.env}-rg"
  location            = "${var.location}"

  name = "${var.product}-${var.env}-mi"

  tags = "${var.common_tags}"
  count = "${var.create_managed_identity ? 1 : 0}"
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


resource "azurerm_key_vault_access_policy" "implicit_managed_identity_access_policy" {
  key_vault_id = "${azurerm_key_vault.kv.id}"

  object_id = "${element(azurerm_user_assigned_identity.managed_identity.*.principal_id, 0)}"
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

  count = "${var.create_managed_identity ? 1 : 0}"
}
