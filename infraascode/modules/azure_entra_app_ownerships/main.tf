locals {
  registration_owners = {
    for idx, item in var.ownerships :
    "${item.managed_app}__${item.owner_app}__reg_${idx}" => item
    if item.assign_app_owner
  }
}

resource "azuread_application_owner" "registration" {
  for_each = local.registration_owners

  application_id  = var.application_resource_ids[each.value.managed_app]
  owner_object_id = var.service_principal_object_ids[each.value.owner_app]
}
