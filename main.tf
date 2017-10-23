provider "azurerm" {}

data "azurerm_client_config" "current" {}

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

    certificate_permissions = [
      "all",
    ]

    key_permissions = [
      "all",
        ]

    secret_permissions = [
      "all",
    ]
  }

  access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "abfa0a7c-a6b6-4736-8310-5855508787cd"

    certificate_permissions = [
      "create",
      "get",
      "getissuers",
      "import",
      "list",
      "ListIssuers",
      "Update",
    ]

    key_permissions = [
      "create",
      "list",
      "get",
      "delete",
      "Update",
      "Import",
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
