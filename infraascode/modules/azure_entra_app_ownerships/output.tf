output "registration_owner_ids" {
  description = "Map of assigned App Registration owner resource IDs."
  value = {
    for k, r in azuread_application_owner.registration : k => r.id
  }
}

output "enterprise_app_owner_ids" {
  description = "Map of assigned Service Principal (Enterprise Application) owner resource IDs."
  value = {
    for k, r in azuread_service_principal_owner.enterprise_app : k => r.id
  }
}