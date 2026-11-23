locals {
  azure_custom_role_definitions = {
    vnet_peering_operator_mg = {
      name        = "Custom VNet Peering Operator"
      scope       = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
      description = "Allows VNet peering actions across spoke VNets under the management group."
      permissions = [
        "Microsoft.Network/virtualNetworks/read",
        "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
        "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write",
        "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete",
        "Microsoft.Network/virtualNetworks/peer/action"
      ]
      not_actions = []
      assignable_scopes = [
        "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
      ]
    }
  }
}