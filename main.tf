provider "azurerm" {}

resource "azurerm_key_vault" "kv" {
  name                = "${var.name}-${var.env}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  sku {
    name = "standard"
  }

  tenant_id = "${var.tenant_id}"

  access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "${var.object_id}"

    key_permissions = [
      "get",
      "list",
      "create",
      "backup",
      "decrypt",
      "delete",
      "encrypt",
      "import",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey",
    ]

    secret_permissions = [
      "get",
      "list",
      "set",
      "delete",
      "backup",
      "purge",
      "recover",
      "restore",
    ]

    certificate_permissions = [
      "create",
      "delete",
      "deleteissuers",
      "get",
      "getissuers",
      "import",
      "list",
      "listissuers",
      "managecontacts",
      "manageissuers",
      "setissuers",
      "update",
    ]
  }

  enabled_for_disk_encryption = true
  enabled_for_deployment = true
  enabled_for_template_deployment = true

  tags {
    environment = "${var.env}"
  }
}
