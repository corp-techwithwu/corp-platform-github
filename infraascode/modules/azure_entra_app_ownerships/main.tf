locals {
  all_app_display_names = toset(flatten([
    for item in var.ownerships : [
      item.managed_app,
      item.owner_app
    ]
  ]))

  registration_owners = {
    for idx, item in var.ownerships :
    "${item.managed_app}__${item.owner_app}__reg_${idx}" => item
    if item.assign_app_owner
  }

  enterprise_app_owners = {
    for idx, item in var.ownerships :
    "${item.managed_app}__${item.owner_app}__sp_${idx}" => item
    if item.assign_sp_owner
  }
}

data "azuread_application" "apps" {
  for_each     = local.all_app_display_names
  display_name = each.value
}

data "azuread_service_principals" "sps" {
  display_names = tolist(local.all_app_display_names)
}

locals {
  sp_object_id_by_display_name = {
    for sp in data.azuread_service_principals.sps.service_principals :
    sp.display_name => sp.object_id
  }
}

resource "azuread_application_owner" "registration" {
  for_each = local.registration_owners

  application_id  = data.azuread_application.apps[each.value.managed_app].object_id
  owner_object_id = local.sp_object_id_by_display_name[each.value.owner_app]
}

resource "azuread_service_principal_owner" "enterprise_app" {
  for_each = local.enterprise_app_owners

  service_principal_id = local.sp_object_id_by_display_name[each.value.managed_app]
  owner_object_id      = local.sp_object_id_by_display_name[each.value.owner_app]
}