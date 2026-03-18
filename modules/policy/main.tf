resource "azurerm_management_group_policy_assignment" "lz" {
  for_each = var.policy_assignments

  name                 = each.key
  management_group_id  = var.management_group_id
  policy_definition_id = each.value.policy_definition_id
  description          = each.value.description
  parameters           = length(each.value.parameters) > 0 ? jsonencode(each.value.parameters) : null
}
