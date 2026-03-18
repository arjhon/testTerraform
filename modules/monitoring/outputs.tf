output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.lz.id
}

output "log_analytics_workspace_key" {
  description = "Primary shared key of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.lz.primary_shared_key
  sensitive   = true
}

output "monitoring_resource_group_id" {
  description = "Resource ID of the monitoring resource group."
  value       = azurerm_resource_group.monitoring.id
}
