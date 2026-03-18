variable "resource_group_name" {
  description = "Name of the resource group for monitoring resources."
  type        = string
}

variable "location" {
  description = "Azure region for monitoring resources."
  type        = string
}

variable "log_analytics_workspace" {
  description = "Configuration for the Log Analytics workspace."
  type = object({
    name              = string
    sku               = optional(string, "PerGB2018")
    retention_in_days = optional(number, 90)
  })
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

variable "tags" {
  description = "Tags to apply to monitoring resources."
  type        = map(string)
  default     = {}
}
