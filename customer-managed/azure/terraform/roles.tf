resource "azurerm_role_definition" "redpanda_agent" {
  assignable_scopes = toset([azurerm_resource_group.redpanda.id, azurerm_resource_group.network.id, azurerm_resource_group.storage.id, azurerm_resource_group.iam.id])
  name              = "${var.resource_name_prefix}${var.redpanda_agent_role_name}"
  scope             = azurerm_resource_group.redpanda.id
  description       = "Redpanda Agent Role"
  permissions {

    actions = [
      # Ability to read the resource group
      "Microsoft.Resources/subscriptions/resourcegroups/read",
      # Storage Containers
      "Microsoft.Storage/storageAccounts/blobServices/containers/delete",
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/write",
      "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action",
      # Create DNS Zones
      "Microsoft.Network/dnszones/read",
      "Microsoft.Network/dnszones/write",
      "Microsoft.Network/dnszones/delete",
      # Workaround for TF needing to import the zone when it already exists.
      "Microsoft.Network/dnszones/SOA/read",
      # Private link read
      "Microsoft.Network/privatelinkservices/read",
      # The agent needs access to the storage account in order to access the data
      "Microsoft.Storage/storageAccounts/read",
      # Manage AKS Clusters
      "Microsoft.ContainerService/managedClusters/read",
      "Microsoft.ContainerService/managedClusters/delete",
      "Microsoft.ContainerService/managedClusters/write",
      "Microsoft.ContainerService/managedClusters/agentPools/read",
      "Microsoft.ContainerService/managedClusters/agentPools/write",
      "Microsoft.ContainerService/managedClusters/agentPools/delete",
      "Microsoft.ContainerService/managedClusters/agentPools/upgradeNodeImageVersion/action",
      # Without this, cannot create node pools to the specified AKS cluster
      "Microsoft.ContainerService/managedClusters/listClusterUserCredential/action",
      # Allows joining to a VNet
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/read",
      "Microsoft.Network/virtualNetworks/subnets/write",
      "Microsoft.Network/virtualNetworks/subnets/delete",
      # Allow agent to manage role assignments for the Redpanda cluster
      "Microsoft.Authorization/roleAssignments/read",
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleAssignments/delete",
      # Allow agent to manage role definitions for the Redpana cluster
      "Microsoft.Authorization/roleDefinitions/write",
      "Microsoft.Authorization/roleDefinitions/read",
      "Microsoft.Authorization/roleDefinitions/delete",
      # Allow agent to manage identities for the Redpanda cluster
      "Microsoft.ManagedIdentity/userAssignedIdentities/read",
      "Microsoft.ManagedIdentity/userAssignedIdentities/write",
      "Microsoft.ManagedIdentity/userAssignedIdentities/delete",
      "Microsoft.ManagedIdentity/userAssignedIdentities/assign/action",
      "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/read",
      "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/write",
      "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/delete",
      # Allow agent to manage tiered storage bucket for the Redpanda cluster
      "Microsoft.Storage/storageAccounts/read",
      "Microsoft.Storage/storageAccounts/write",
      "Microsoft.Storage/storageAccounts/delete",
      "Microsoft.Storage/storageAccounts/blobServices/read",
      "Microsoft.Storage/storageAccounts/blobServices/write",
      # Allow agent to read public IPs
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Network/publicIPAddresses/write",
      "Microsoft.Network/publicIPAddresses/delete",
      # Creating the RP storage account requires these additional permissions to workaround  https://github.com/hashicorp/terraform-provider-azurerm/issues/25521
      "Microsoft.Storage/storageAccounts/queueServices/read",
      "Microsoft.Storage/storageAccounts/fileServices/read",
      "Microsoft.Storage/storageAccounts/fileServices/shares/read",
      "Microsoft.Storage/storageAccounts/listkeys/action",
      # Read the keyvault
      "Microsoft.KeyVault/vaults/read"
    ]
    data_actions = [
      # Storage Containers
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/move/action",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action"
    ]
  }
}

resource "azurerm_role_definition" "redpanda_console" {
  name        = "${var.resource_name_prefix}${var.redpanda_console_role_name}"
  description = "Redpanda Console Role"
  scope       = azurerm_resource_group.redpanda.id
  assignable_scopes = [
    azurerm_resource_group.redpanda.id
  ]
  permissions {
    # https://learn.microsoft.com/en-us/azure/role-based-access-control/permissions/security#microsoftkeyvault
    actions = [
      "Microsoft.KeyVault/vaults/secrets/read",
      "Microsoft.KeyVault/vaults/secrets/write",
    ]
    data_actions = [
      "Microsoft.KeyVault/vaults/secrets/update/action",
      "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
      "Microsoft.KeyVault/vaults/secrets/delete",
      "Microsoft.KeyVault/vaults/secrets/setSecret/action"
    ]
  }
}

resource "azurerm_role_definition" "redpanda_private_link" {
  assignable_scopes = [
    azurerm_resource_group.redpanda.id
  ]
  name        = "${var.resource_name_prefix}${var.redpanda_private_link_role_name}"
  scope       = azurerm_resource_group.redpanda.id
  description = "Redpanda AKS Private Link Service"
  permissions {

    actions = [
      "Microsoft.Network/privatelinkservices/read",
      "Microsoft.Network/privateLinkServices/write",
      "Microsoft.Network/privateLinkServices/delete",
      "Microsoft.Network/privateLinkServices/privateEndpointConnections/read",
      "Microsoft.Network/privateLinkServices/privateEndpointConnections/write",
      "Microsoft.Network/privateLinkServices/privateEndpointConnections/delete"
    ]
  }
}

resource "azurerm_role_definition" "kafka_connect" {
  name        = "${var.resource_name_prefix}${var.kafka_connect_role_name}"
  description = "Redpanda Kafka Connect Role"
  scope       = azurerm_resource_group.redpanda.id
  assignable_scopes = [
    azurerm_resource_group.redpanda.id
  ]
  permissions {
    # https://learn.microsoft.com/en-us/azure/role-based-access-control/permissions/security#microsoftkeyvault
    actions = [
      "Microsoft.KeyVault/vaults/secrets/read",
    ]
    data_actions = [
      "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
    ]
  }
}
