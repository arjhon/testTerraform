# ── General ────────────────────────────────────────────────────────────────────
variable "environment" {
  description = "The environment name (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
  default     = "eastus"
}

variable "landing_zone_name" {
  description = "Logical name for this landing zone deployment."
  type        = string
  default     = "azure-lz"
}

variable "tenant_id" {
  description = "The Azure AD tenant ID."
  type        = string
}

variable "default_tags" {
  description = "A map of default tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# ── Management Groups ──────────────────────────────────────────────────────────
variable "root_management_group_id" {
  description = "The ID of the root management group (tenant root group)."
  type        = string
}

variable "root_management_group_name" {
  description = "The display name for the root management group."
  type        = string
  default     = "Landing Zone"
}

variable "management_groups" {
  description = "Map of child management groups to create under the root."
  type = map(object({
    display_name               = string
    parent_management_group_id = optional(string)
  }))
  default = {}
}

# ── Networking ─────────────────────────────────────────────────────────────────
variable "hub_resource_group_name" {
  description = "Name of the resource group for hub networking resources."
  type        = string
  default     = "rg-hub-network"
}

variable "hub_vnet_name" {
  description = "Name of the hub virtual network."
  type        = string
  default     = "vnet-hub"
}

variable "hub_vnet_cidr" {
  description = "CIDR block for the hub virtual network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "hub_subnets" {
  description = "Map of subnets to create inside the hub virtual network."
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
  }))
  default = {
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
}

variable "spoke_vnets" {
  description = "Map of spoke virtual networks to create and peer with the hub."
  type = map(object({
    resource_group_name = string
    vnet_cidr           = string
    subnets = map(object({
      address_prefixes  = list(string)
      service_endpoints = optional(list(string), [])
    }))
  }))
  default = {}
}

variable "enable_vpn_gateway" {
  description = "Whether to deploy an Azure VPN Gateway in the hub."
  type        = bool
  default     = false
}

variable "enable_firewall" {
  description = "Whether to deploy an Azure Firewall in the hub."
  type        = bool
  default     = false
}

# ── Identity ───────────────────────────────────────────────────────────────────
variable "identity_resource_group_name" {
  description = "Name of the resource group for identity resources."
  type        = string
  default     = "rg-identity"
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault for secret management."
  type        = string
  default     = "kv-landingzone"
}

variable "admin_group_object_ids" {
  description = "List of Azure AD group object IDs to assign the Owner role."
  type        = list(string)
  default     = []
}

variable "reader_group_object_ids" {
  description = "List of Azure AD group object IDs to assign the Reader role."
  type        = list(string)
  default     = []
}

# ── Policy ─────────────────────────────────────────────────────────────────────
variable "policy_assignments" {
  description = "Map of built-in Azure Policy initiatives to assign."
  type = map(object({
    policy_definition_id = string
    description          = optional(string, "")
    parameters           = optional(map(string), {})
  }))
  default = {}
}

# ── Monitoring ─────────────────────────────────────────────────────────────────
variable "monitoring_resource_group_name" {
  description = "Name of the resource group for monitoring resources."
  type        = string
  default     = "rg-monitoring"
}

variable "log_analytics_workspace" {
  description = "Configuration for the Log Analytics workspace."
  type = object({
    name              = string
    sku               = optional(string, "PerGB2018")
    retention_in_days = optional(number, 90)
  })
  default = {
    name = "law-landingzone"
  }
}

variable "security_center_contact" {
  description = "Microsoft Defender for Cloud contact information."
  type = object({
    email               = string
    phone               = optional(string, "")
    alert_notifications = optional(bool, true)
    alerts_to_admins    = optional(bool, true)
  })
  default = null
}
