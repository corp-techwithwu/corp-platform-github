variable "custom_roles" {
  description = "Map of custom role definitions to create in Azure."
  type = map(object({
    name              = string
    scope             = string
    description       = optional(string, "")
    permissions       = list(string)
    not_actions       = optional(list(string), [])
    data_actions      = optional(list(string), [])
    not_data_actions  = optional(list(string), [])
    assignable_scopes = list(string)
  }))
  default = {}
}