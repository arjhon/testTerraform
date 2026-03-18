variable "resource_group_name" {
  description = "Name of the resource group for hub networking resources."
  type        = string
}

variable "location" {
  description = "Azure region for all networking resources."
  type        = string
}

variable "hub_vnet_name" {
  description = "Name of the hub virtual network."
  type        = string
}

variable "hub_vnet_cidr" {
  description = "CIDR block for the hub virtual network."
  type        = string
}

variable "hub_subnets" {
  description = "Map of subnets to create in the hub virtual network."
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
  }))
}

variable "spoke_vnets" {
  description = "Map of spoke virtual networks to peer with the hub."
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
  description = "Deploy an Azure VPN Gateway in the hub."
  type        = bool
  default     = false
}

variable "enable_firewall" {
  description = "Deploy an Azure Firewall in the hub."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all networking resources."
  type        = map(string)
  default     = {}
}
