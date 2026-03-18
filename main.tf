locals {
  tags = merge(var.default_tags, {
    environment  = var.environment
    managed_by   = "terraform"
    landing_zone = var.landing_zone_name
  })
}

# ── Management Groups ──────────────────────────────────────────────────────────
module "management_groups" {
  source = "./modules/management_groups"

  root_management_group_id   = var.root_management_group_id
  root_management_group_name = var.root_management_group_name
  management_groups          = var.management_groups
}

# ── Networking ─────────────────────────────────────────────────────────────────
module "networking" {
  source = "./modules/networking"

  resource_group_name  = var.hub_resource_group_name
  location             = var.location
  hub_vnet_name        = var.hub_vnet_name
  hub_vnet_cidr        = var.hub_vnet_cidr
  hub_subnets          = var.hub_subnets
  spoke_vnets          = var.spoke_vnets
  enable_vpn_gateway   = var.enable_vpn_gateway
  enable_firewall      = var.enable_firewall
  tags                 = local.tags
}

# ── Identity ───────────────────────────────────────────────────────────────────
module "identity" {
  source = "./modules/identity"

  resource_group_name       = var.identity_resource_group_name
  location                  = var.location
  key_vault_name            = var.key_vault_name
  tenant_id                 = var.tenant_id
  admin_group_object_ids    = var.admin_group_object_ids
  reader_group_object_ids   = var.reader_group_object_ids
  tags                      = local.tags
}

# ── Policy ─────────────────────────────────────────────────────────────────────
module "policy" {
  source = "./modules/policy"

  management_group_id = module.management_groups.root_management_group_id
  policy_assignments  = var.policy_assignments
  tags                = local.tags
}

# ── Monitoring ─────────────────────────────────────────────────────────────────
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name       = var.monitoring_resource_group_name
  location                  = var.location
  log_analytics_workspace   = var.log_analytics_workspace
  security_center_contact   = var.security_center_contact
  tags                      = local.tags
}
