output "registration_owner_ids" {
  description = "Map of assigned App Registration owner resource IDs."
  value = {
    for k, r in azuread_application_owner.registration : k => r.id
  }
}