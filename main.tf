locals {
  vaultName = "${var.name == "" ? format("%s-%s", var.product, var.env) : var.name}"
}

resource "azurerm_key_vault" "kv" {
  name                = "${local.vaultName}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  sku {
    name = "${var.sku}"
  }

  tenant_id = "${var.tenant_id}"

  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  tags = "${var.common_tags}"
}

resource "azurerm_key_vault_access_policy" "creator_access_policy" {
  key_vault_id = "${azurerm_key_vault.kv.id}"

  object_id = "${var.object_id}"
  tenant_id = "${var.tenant_id}"

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
  ]
}

resource "azurerm_key_vault_access_policy" "product_team_access_policy" {
  key_vault_id = "${azurerm_key_vault.kv.id}"

  object_id = "${var.product_group_object_id}"
  tenant_id = "${var.tenant_id}"

  key_permissions = [
    "list",
    "update",
    "create",
    "import",
    "delete",
  ]

  certificate_permissions = [
    "list",
    "update",
    "create",
    "import",
    "delete",
    "managecontacts",
    "manageissuers",
    "getissuers",
    "listissuers",
    "setissuers",
    "deleteissuers",
  ]

  secret_permissions = [
    "list",
    "set",
    "delete",
  ]
}
