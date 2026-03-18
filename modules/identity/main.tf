data "azurerm_client_config" "current" {}

# ── Identity Resource Group ────────────────────────────────────────────────────
resource "azurerm_resource_group" "identity" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ── Key Vault ──────────────────────────────────────────────────────────────────
resource "azurerm_key_vault" "lz" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.identity.location
  resource_group_name         = azurerm_resource_group.identity.name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
  tags                        = var.tags
}

# ── RBAC: Key Vault Administrator for deployment principal ─────────────────────
resource "azurerm_role_assignment" "kv_admin_deployer" {
  scope                = azurerm_key_vault.lz.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# ── RBAC: Owner role for admin groups ──────────────────────────────────────────
resource "azurerm_role_assignment" "owner" {
  for_each = toset(var.admin_group_object_ids)

  scope                = azurerm_resource_group.identity.id
  role_definition_name = "Owner"
  principal_id         = each.value
}

# ── RBAC: Reader role for reader groups ───────────────────────────────────────
resource "azurerm_role_assignment" "reader" {
  for_each = toset(var.reader_group_object_ids)

  scope                = azurerm_resource_group.identity.id
  role_definition_name = "Reader"
  principal_id         = each.value
}
