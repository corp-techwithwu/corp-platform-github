locals {
  raw_azure_entra_app_ownerships = csvdecode(file("${local.config_path}/azure-identity/entra_app_ownerships.csv"))

  azure_entra_app_ownerships = [
    for row in local.raw_azure_entra_app_ownerships : {
      managed_app      = trimspace(row.managed_app)
      owner_app        = trimspace(row.owner_app)
      assign_app_owner = tobool(lower(trimspace(row.assign_app_owner)))
      purpose          = trimspace(row.purpose)
    }
  ]
}