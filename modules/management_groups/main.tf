resource "azurerm_management_group" "root" {
  name         = var.root_management_group_id
  display_name = var.root_management_group_name
}

resource "azurerm_management_group" "children" {
  for_each = var.management_groups

  name         = each.key
  display_name = each.value.display_name

  parent_management_group_id = coalesce(
    each.value.parent_management_group_id,
    azurerm_management_group.root.id
  )

  depends_on = [azurerm_management_group.root]
}
