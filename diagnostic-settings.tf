resource "azurerm_monitor_diagnostic_setting" "kv-ds" {
  name                       = local.vault_name
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = module.log_analytics_workspace.workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

module "log_analytics_workspace" {
  source      = "git::https://github.com/hmcts/terraform-module-log-analytics-workspace-id.git?ref=master"
  environment = var.env
}
