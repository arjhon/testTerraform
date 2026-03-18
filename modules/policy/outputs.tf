output "policy_assignment_ids" {
  description = "Map of policy assignment keys to their resource IDs."
  value       = { for k, v in azurerm_management_group_policy_assignment.lz : k => v.id }
}
