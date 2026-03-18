# ── Monitoring Resource Group ──────────────────────────────────────────────────
resource "azurerm_resource_group" "monitoring" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ── Log Analytics Workspace ────────────────────────────────────────────────────
resource "azurerm_log_analytics_workspace" "lz" {
  name                = var.log_analytics_workspace.name
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = var.log_analytics_workspace.sku
  retention_in_days   = var.log_analytics_workspace.retention_in_days
  tags                = var.tags
}

# ── Microsoft Defender for Cloud Contact (optional) ────────────────────────────
resource "azurerm_security_center_contact" "lz" {
  count = var.security_center_contact != null ? 1 : 0

  email               = var.security_center_contact.email
  phone               = var.security_center_contact.phone
  alert_notifications = var.security_center_contact.alert_notifications
  alerts_to_admins    = var.security_center_contact.alerts_to_admins
}

# ── Microsoft Defender for Cloud – enable standard plans ─────────────────────
resource "azurerm_security_center_subscription_pricing" "defender_servers" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "defender_storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_subscription_pricing" "defender_sql" {
  tier          = "Standard"
  resource_type = "SqlServers"
}

resource "azurerm_security_center_subscription_pricing" "defender_keyvault" {
  tier          = "Standard"
  resource_type = "KeyVaults"
}
