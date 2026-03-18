# ── Hub Resource Group ─────────────────────────────────────────────────────────
resource "azurerm_resource_group" "hub" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ── Hub Virtual Network ────────────────────────────────────────────────────────
resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [var.hub_vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "hub" {
  for_each = var.hub_subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints
}

# ── Azure Firewall (optional) ──────────────────────────────────────────────────
resource "azurerm_public_ip" "firewall" {
  count = var.enable_firewall ? 1 : 0

  name                = "pip-${var.hub_vnet_name}-fw"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "hub" {
  count = var.enable_firewall ? 1 : 0

  name                = "fw-${var.hub_vnet_name}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  tags                = var.tags

  ip_configuration {
    name                 = "firewall-ipconfig"
    subnet_id            = azurerm_subnet.hub["AzureFirewallSubnet"].id
    public_ip_address_id = azurerm_public_ip.firewall[0].id
  }
}

# ── VPN Gateway (optional) ─────────────────────────────────────────────────────
resource "azurerm_public_ip" "vpn_gateway" {
  count = var.enable_vpn_gateway ? 1 : 0

  name                = "pip-${var.hub_vnet_name}-vpngw"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "hub" {
  count = var.enable_vpn_gateway ? 1 : 0

  name                = "vpngw-${var.hub_vnet_name}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  active_active       = false
  enable_bgp          = false
  tags                = var.tags

  ip_configuration {
    name                          = "vpngw-ipconfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub["GatewaySubnet"].id
  }
}

# ── Spoke Virtual Networks ─────────────────────────────────────────────────────
resource "azurerm_resource_group" "spoke" {
  for_each = var.spoke_vnets

  name     = each.value.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "spoke" {
  for_each = var.spoke_vnets

  name                = each.key
  location            = azurerm_resource_group.spoke[each.key].location
  resource_group_name = azurerm_resource_group.spoke[each.key].name
  address_space       = [each.value.vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "spoke" {
  for_each = {
    for pair in flatten([
      for vnet_key, vnet in var.spoke_vnets : [
        for subnet_key, subnet in vnet.subnets : {
          key              = "${vnet_key}/${subnet_key}"
          vnet_key         = vnet_key
          subnet_key       = subnet_key
          address_prefixes = subnet.address_prefixes
          service_endpoints = subnet.service_endpoints
        }
      ]
    ]) : pair.key => pair
  }

  name                 = each.value.subnet_key
  resource_group_name  = azurerm_resource_group.spoke[each.value.vnet_key].name
  virtual_network_name = azurerm_virtual_network.spoke[each.value.vnet_key].name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints
}

# ── Hub-to-Spoke VNet Peerings ─────────────────────────────────────────────────
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = var.spoke_vnets

  name                         = "peer-hub-to-${each.key}"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke[each.key].id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.enable_vpn_gateway
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = var.spoke_vnets

  name                         = "peer-${each.key}-to-hub"
  resource_group_name          = azurerm_resource_group.spoke[each.key].name
  virtual_network_name         = azurerm_virtual_network.spoke[each.key].name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = var.enable_vpn_gateway
}
