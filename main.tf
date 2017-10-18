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
      "set",
    ]

    secret_permissions = [
      "get",
      "list",
      "set",
    ]
  }

  enabled_for_disk_encryption = true

  tags {
    environment = "${var.env}"
  }
}
