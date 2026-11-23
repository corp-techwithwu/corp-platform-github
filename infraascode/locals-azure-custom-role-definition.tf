locals {
  azure_custom_role_definitions = {
    vnet_peering_reader_and_peer_alz = {
      name        = "VNet Peering Reader & Peer(alz)"
      scope       = "/providers/Microsoft.Management/managementGroups/alz"
      description = "Allows VNet peering actions across spoke VNets under the management group."
      permissions = [
        "Microsoft.Network/virtualNetworks/read",
        "Microsoft.Network/virtualNetworks/peer/action"
      ]
      not_actions = []
      assignable_scopes = [
        "/providers/Microsoft.Management/managementGroups/alz"
      ]
    },
    bicep_what_if_alz = {
      name        = "Bicep What If(alz)"
      scope       = "/providers/Microsoft.Management/managementGroups/alz"
      description = "Allows Bicep to run whatIf command"
      permissions = [
        "*/read",
        "Microsoft.Resources/deployments/whatIf/action",
        "Microsoft.Resources/deployments/validate/action"
      ]
      not_actions = []
      assignable_scopes = [
        "/providers/Microsoft.Management/managementGroups/alz"
      ]
    }
  }
}