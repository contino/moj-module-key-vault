data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {

  name                = "${var.product}-${var.env}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  sku {
    name = "standard"
  }

  tenant_id = "${var.tenant_id}"

  access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "${var.object_id}"

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

  enabled_for_disk_encryption = true
  enabled_for_deployment = true
  enabled_for_template_deployment = true

  tags {
    environment = "${var.env}"
  }
}
