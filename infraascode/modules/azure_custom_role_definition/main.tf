resource "azurerm_role_definition" "this" {
  for_each = var.custom_roles

  name        = each.value.name
  scope       = each.value.scope
  description = each.value.description

  permissions {
    actions          = each.value.permissions
    not_actions      = each.value.not_actions
    data_actions     = each.value.data_actions
    not_data_actions = each.value.not_data_actions
  }

  assignable_scopes = each.value.assignable_scopes
}