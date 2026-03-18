output "management_group_ids" {
  description = "Map of management group names to their IDs."
  value       = module.management_groups.management_group_ids
}

output "hub_vnet_id" {
  description = "Resource ID of the hub virtual network."
  value       = module.networking.hub_vnet_id
}

output "hub_vnet_name" {
  description = "Name of the hub virtual network."
  value       = module.networking.hub_vnet_name
}

output "spoke_vnet_ids" {
  description = "Map of spoke virtual network names to their resource IDs."
  value       = module.networking.spoke_vnet_ids
}

output "key_vault_id" {
  description = "Resource ID of the landing zone Key Vault."
  value       = module.identity.key_vault_id
}

output "key_vault_uri" {
  description = "URI of the landing zone Key Vault."
  value       = module.identity.key_vault_uri
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = module.monitoring.log_analytics_workspace_id
}

output "log_analytics_workspace_key" {
  description = "Primary shared key for the Log Analytics workspace."
  value       = module.monitoring.log_analytics_workspace_key
  sensitive   = true
}
