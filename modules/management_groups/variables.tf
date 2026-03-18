variable "root_management_group_id" {
  description = "The ID (name) for the root management group."
  type        = string
}

variable "root_management_group_name" {
  description = "The display name for the root management group."
  type        = string
}

variable "management_groups" {
  description = "Map of child management groups to create."
  type = map(object({
    display_name               = string
    parent_management_group_id = optional(string)
  }))
  default = {}
}
