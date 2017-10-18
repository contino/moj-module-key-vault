provider "azurerm" {}

resource "azurerm_key_vault" "kv" {
  name                = "${var.name}-${var.env}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  sku {
    name = "standard"
  }

  access_policy {
    tenant_id = "${var.tenant_id}"

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]
  }

  enabled_for_disk_encryption = true

  tags {
    environment = "${var.env}"
  }
}
