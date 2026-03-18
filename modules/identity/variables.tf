variable "resource_group_name" {
  description = "Name of the resource group for identity resources."
  type        = string
}

variable "location" {
  description = "Azure region for identity resources."
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault."
  type        = string
}

variable "tenant_id" {
  description = "The Azure AD tenant ID."
  type        = string
}

variable "admin_group_object_ids" {
  description = "Azure AD group object IDs to grant Owner access."
  type        = list(string)
  default     = []
}

variable "reader_group_object_ids" {
  description = "Azure AD group object IDs to grant Reader access."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to identity resources."
  type        = map(string)
  default     = {}
}
