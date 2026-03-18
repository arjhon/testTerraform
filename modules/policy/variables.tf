variable "management_group_id" {
  description = "Resource ID of the management group to assign policies to."
  type        = string
}

variable "policy_assignments" {
  description = "Map of Azure Policy assignments."
  type = map(object({
    policy_definition_id = string
    description          = optional(string, "")
    parameters           = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "Tags (unused in policy module, reserved for future use)."
  type        = map(string)
  default     = {}
}
