variable "ownerships" {
  description = "List of Entra ID ownership assignments between a managed app and an owner app."
  type = list(object({
    managed_app                                   = string
    owner_app                                     = string
    assign_app_owner    = bool
    assign_sp_owner = bool
    purpose                                       = optional(string, "")
  }))
}