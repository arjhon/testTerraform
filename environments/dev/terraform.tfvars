# ── General ────────────────────────────────────────────────────────────────────
environment       = "dev"
location          = "westeurope"
landing_zone_name = "azure-lz"
tenant_id         = "<YOUR_TENANT_ID>"

default_tags = {
  owner      = "platform-team"
  project    = "azure-landing-zone"
  cost_center = "cc-001"
}

# ── Management Groups ──────────────────────────────────────────────────────────
root_management_group_id   = "mg-landingzone"
root_management_group_name = "Landing Zone"

management_groups = {
  mg-platform = {
    display_name = "Platform"
  }
  mg-workloads = {
    display_name = "Workloads"
  }
  mg-sandbox = {
    display_name = "Sandbox"
  }
}

# ── Networking ─────────────────────────────────────────────────────────────────
hub_resource_group_name = "rg-hub-network-dev"
hub_vnet_name           = "vnet-hub-dev"
hub_vnet_cidr           = "10.0.0.0/16"
enable_vpn_gateway      = false
enable_firewall         = false

hub_subnets = {
  GatewaySubnet = {
    address_prefixes = ["10.0.0.0/27"]
  }
  AzureFirewallSubnet = {
    address_prefixes = ["10.0.1.0/26"]
  }
  ManagementSubnet = {
    address_prefixes = ["10.0.2.0/24"]
  }
}

spoke_vnets = {
  vnet-workloads-dev = {
    resource_group_name = "rg-workloads-network-dev"
    vnet_cidr           = "10.1.0.0/16"
    subnets = {
      app-subnet = {
        address_prefixes  = ["10.1.0.0/24"]
        service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      }
      data-subnet = {
        address_prefixes = ["10.1.1.0/24"]
      }
    }
  }
}

# ── Identity ───────────────────────────────────────────────────────────────────
identity_resource_group_name = "rg-identity-dev"
key_vault_name               = "kv-lz-dev"
admin_group_object_ids       = []
reader_group_object_ids      = []

# ── Policy ─────────────────────────────────────────────────────────────────────
policy_assignments = {}

# ── Monitoring ─────────────────────────────────────────────────────────────────
monitoring_resource_group_name = "rg-monitoring-dev"

log_analytics_workspace = {
  name              = "law-lz-dev"
  sku               = "PerGB2018"
  retention_in_days = 30
}

security_center_contact = null
