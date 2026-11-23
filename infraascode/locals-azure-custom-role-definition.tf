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
    deployment_stacks_whatif_operator_with_no_rbac_alz = {
      name        = "Deployment Stacks What-If Operator With No RBAC(alz)"
      scope       = "/providers/Microsoft.Management/managementGroups/alz"
      description = "Permissions to create deployment stack what-if results alongside Reader with ProviderNoRbac."
      permissions = [
        "*/read",
        "Microsoft.Resources/deployments/whatIf/action",
        "Microsoft.Resources/deploymentStacksWhatIfResults/write",
        "Microsoft.Resources/deploymentStacks/manageDenySetting/action"
      ]
      not_actions = []
      assignable_scopes = [
        "/providers/Microsoft.Management/managementGroups/alz"
      ]
    }
  }
}