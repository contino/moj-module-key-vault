locals {
  managed_identity_list = toset(compact(concat(var.managed_identity_object_ids, [var.managed_identity_object_id])))
  namespace             = var.namespace != null ? var.namespace : var.product
  aks_prefix            = var.businessArea == "SDS" ? "ss" : "cft"
}
resource "azurerm_user_assigned_identity" "managed_identity" {

  resource_group_name = "managed-identities-${var.env}-rg"
  location            = var.location

  name = "${var.product}-${var.env}-mi"

  tags  = var.common_tags
  count = var.create_managed_identity ? 1 : 0
}

data "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  count               = 2
  provider            = azurerm.aks_subscription
  name                = "${local.aks_prefix}-${var.env}-0${count.index}-aks"
  resource_group_name = "${local.aks_prefix}-${var.env}-0${count.index}-rg"
}

resource "azurerm_federated_identity_credential" "federated_credential" {
  name                = "${var.product}-${var.env}-fdc"
  resource_group_name = "managed-identities-${var.env}-rg"
  audience            = ["api://AzureADTokenExchange"]
  issuer              = data.azurerm_kubernetes_cluster.kubernetes_cluster[*].oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.managed_identity.id
  subject             = "system:serviceaccount:${local.namespace}:${local.namespace}"
}

resource "azurerm_key_vault_access_policy" "managed_identity_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  object_id    = each.value
  tenant_id    = data.azurerm_client_config.current.tenant_id

  key_permissions = [
    "Get",
    "List",
  ]

  certificate_permissions = [
    "Get",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]

  for_each = local.managed_identity_list
}


resource "azurerm_key_vault_access_policy" "implicit_managed_identity_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id

  object_id = azurerm_user_assigned_identity.managed_identity[0].principal_id
  tenant_id = data.azurerm_client_config.current.tenant_id

  key_permissions = [
    "Get",
    "List",
  ]

  certificate_permissions = [
    "Get",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]

  count = var.create_managed_identity ? 1 : 0
}
