variable "ownerships" {
  description = "List of Entra ID ownership assignments between a managed app and an owner app."
  type = list(object({
    managed_app      = string
    owner_app        = string
    assign_app_owner = bool
    purpose          = optional(string, "")
  }))
}

variable "application_resource_ids" {
  description = "Map of application names to Azure AD application resource IDs."
  type        = map(string)
}

variable "service_principal_object_ids" {
  description = "Map of service principal names to Azure AD object IDs."
  type        = map(string)
}