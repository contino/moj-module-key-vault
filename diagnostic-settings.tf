resource "azurerm_monitor_diagnostic_setting" "kv-ds" {
  count = var.enable_diagnostic_setting ? 1 : 0

  name                       = local.vaultName
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = module.log_analytics_workspace.workspace_id

  log {
    category = "AuditEvent"

    retention_policy {
      enabled = true
      days    = 14
    }
  }
}

module "log_analytics_workspace" {
  count = var.enable_diagnostic_setting ? 1 : 0

  source      = "git::https://github.com/hmcts/terraform-module-log-analytics-workspace-id.git?ref=master"
  environment = var.env
}
