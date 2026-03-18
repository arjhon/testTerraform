output "hub_vnet_id" {
  description = "Resource ID of the hub virtual network."
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Name of the hub virtual network."
  value       = azurerm_virtual_network.hub.name
}

output "hub_subnet_ids" {
  description = "Map of hub subnet names to their resource IDs."
  value       = { for k, v in azurerm_subnet.hub : k => v.id }
}

output "spoke_vnet_ids" {
  description = "Map of spoke virtual network names to their resource IDs."
  value       = { for k, v in azurerm_virtual_network.spoke : k => v.id }
}

output "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall (if deployed)."
  value       = var.enable_firewall ? azurerm_firewall.hub[0].ip_configuration[0].private_ip_address : null
}
