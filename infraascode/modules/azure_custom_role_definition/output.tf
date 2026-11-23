output "role_definitions" {
  description = "Map of created Azure role definitions keyed by role map key."
  value = {
    for k, role in azurerm_role_definition.this : k => {
      id                         = role.id
      role_definition_id         = role.role_definition_id
      role_definition_resource_id = role.role_definition_resource_id
      name                       = role.name
      scope                      = role.scope
    }
  }
}