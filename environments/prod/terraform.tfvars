# ── General ────────────────────────────────────────────────────────────────────
environment       = "prod"
location          = "westeurope"
landing_zone_name = "azure-lz"
tenant_id         = "<YOUR_TENANT_ID>"

default_tags = {
  owner       = "platform-team"
  project     = "azure-landing-zone"
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
  mg-decommissioned = {
    display_name = "Decommissioned"
  }
}

# ── Networking ─────────────────────────────────────────────────────────────────
hub_resource_group_name = "rg-hub-network-prod"
hub_vnet_name           = "vnet-hub-prod"
hub_vnet_cidr           = "10.0.0.0/16"
enable_vpn_gateway      = true
enable_firewall         = true

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
  vnet-workloads-prod = {
    resource_group_name = "rg-workloads-network-prod"
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
  vnet-platform-prod = {
    resource_group_name = "rg-platform-network-prod"
    vnet_cidr           = "10.2.0.0/16"
    subnets = {
      mgmt-subnet = {
        address_prefixes = ["10.2.0.0/24"]
      }
    }
  }
}

# ── Identity ───────────────────────────────────────────────────────────────────
identity_resource_group_name = "rg-identity-prod"
key_vault_name               = "kv-lz-prod"
admin_group_object_ids       = []
reader_group_object_ids      = []

# ── Policy ─────────────────────────────────────────────────────────────────────
# Example: assign CIS Microsoft Azure Foundations Benchmark initiative
policy_assignments = {
  cis-benchmark = {
    policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/612b5213-9160-4969-8578-1518bd2a000c"
    description          = "CIS Microsoft Azure Foundations Benchmark v1.4.0"
  }
}

# ── Monitoring ─────────────────────────────────────────────────────────────────
monitoring_resource_group_name = "rg-monitoring-prod"

log_analytics_workspace = {
  name              = "law-lz-prod"
  sku               = "PerGB2018"
  retention_in_days = 90
}

security_center_contact = {
  email               = "security@example.com"
  phone               = "+1-555-000-0000"
  alert_notifications = true
  alerts_to_admins    = true
}
