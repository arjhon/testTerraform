output "root_management_group_id" {
  description = "Resource ID of the root management group."
  value       = azurerm_management_group.root.id
}

output "management_group_ids" {
  description = "Map of management group keys to their resource IDs."
  value = merge(
    { root = azurerm_management_group.root.id },
    { for k, v in azurerm_management_group.children : k => v.id }
  )
}
