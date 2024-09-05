locals {
  create_role_assignment = var.create_role_assignment ? 1 : 0

  redpanda_operator_namespace = "redpanda"

  # aks_oidc_issuer_url = "https://TODO"
}

// Allow storing Redpanda TF state to storage
resource "azurerm_role_assignment" "assign_identity_storage_blob_data_contributor" {
  count = local.create_role_assignment

  scope                = azurerm_storage_account.management.id
  principal_id         = azurerm_user_assigned_identity.redpanda_agent.principal_id
  role_definition_name = "Storage Blob Data Contributor"
}

// Allow access to key vault
resource "azurerm_role_assignment" "vault_secrets_officer" {
  count = local.create_role_assignment

  scope                = azurerm_resource_group.redpanda.id
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Secrets Officer"
}

resource "azurerm_role_assignment" "redpanda_agent_redpanda" {
  count = local.create_role_assignment

  principal_id       = azurerm_user_assigned_identity.redpanda_agent.principal_id
  scope              = azurerm_resource_group.redpanda.id
  role_definition_id = azurerm_role_definition.redpanda_agent.role_definition_resource_id
}

resource "azurerm_role_assignment" "redpanda_agent_network" {
  count = local.create_role_assignment

  principal_id       = azurerm_user_assigned_identity.redpanda_agent.principal_id
  scope              = azurerm_resource_group.network.id
  role_definition_id = azurerm_role_definition.redpanda_agent.role_definition_resource_id
}

resource "azurerm_role_assignment" "redpanda_agent_tiered_storage" {
  count = local.create_role_assignment

  principal_id       = azurerm_user_assigned_identity.redpanda_agent.principal_id
  scope              = azurerm_resource_group.storage.id
  role_definition_id = azurerm_role_definition.redpanda_agent.role_definition_resource_id
}

resource "azurerm_role_assignment" "redpanda_agent_iam" {
  count = local.create_role_assignment

  principal_id       = azurerm_user_assigned_identity.redpanda_agent.principal_id
  scope              = azurerm_resource_group.iam.id
  role_definition_id = azurerm_role_definition.redpanda_agent.role_definition_resource_id
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  count = local.create_role_assignment

  scope                = azurerm_resource_group.network.id
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "redpanda_private_link" {
  count = local.create_role_assignment

  principal_id       = azurerm_user_assigned_identity.aks.principal_id
  scope              = azurerm_resource_group.redpanda.id
  role_definition_id = azurerm_role_definition.redpanda_private_link.role_definition_resource_id
}

resource "azurerm_role_assignment" "redpanda_cluster" {
  count = local.create_role_assignment

  principal_id = azurerm_user_assigned_identity.redpanda_cluster.principal_id
  # See https://learn.microsoft.com/en-us/azure/role-based-access-control/troubleshooting?tabs=bicep#symptom---assigning-a-role-to-a-new-principal-sometimes-fails
  principal_type       = "ServicePrincipal"
  scope                = azurerm_storage_account.tiered_storage.id
  role_definition_name = "Storage Blob Data Contributor"
}

resource "azurerm_role_assignment" "redpanda_console" {
  count = local.create_role_assignment

  principal_id       = azurerm_user_assigned_identity.redpanda_console.principal_id
  scope              = azurerm_key_vault.console[0].id
  role_definition_id = azurerm_role_definition.redpanda_console.role_definition_resource_id
}

resource "azurerm_role_assignment" "cert_manager" {
  count = local.create_role_assignment
  # In TF provisioner, the scope is a DNS zone specific resource. We change it to RG here since DNS zone is not avaiable until cluster is being deployed.
  # scope                = "/subscriptions/60fc0bed-3072-4c53-906a-d130a934d520/resourceGroups/rg-rpcloud-cqclghd44f471cmf8ojg/providers/Microsoft.Network/dnsZones/cqclghd44f471cmf8ojg.byoc.ign.cloud.redpanda.com"
  scope                = azurerm_resource_group.redpanda.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cert_manager.principal_id
  # See https://learn.microsoft.com/en-us/azure/role-based-access-control/troubleshooting?tabs=bicep#symptom---assigning-a-role-to-a-new-principal-sometimes-fails
  principal_type = "ServicePrincipal"
}

resource "azurerm_role_assignment" "external_dns_zone_contributor" {
  count = local.create_role_assignment
  # In TF provisioner, the scope is a DNS zone specific resource. We change it to RG here since DNS zone is not avaiable until cluster is being deployed.
  #scope                = "/subscriptions/60fc0bed-3072-4c53-906a-d130a934d520/resourceGroups/rg-rpcloud-cqclghd44f471cmf8ojg/providers/Microsoft.Network/dnsZones/cqclghd44f471cmf8ojg.byoc.ign.cloud.redpanda.com"
  scope                = azurerm_resource_group.redpanda.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.external_dns.principal_id
  # See https://learn.microsoft.com/en-us/azure/role-based-access-control/troubleshooting?tabs=bicep#symptom---assigning-a-role-to-a-new-principal-sometimes-fails
  principal_type = "ServicePrincipal"
}

resource "azurerm_role_assignment" "external_dns_rgreader" {
  count                = local.create_role_assignment
  scope                = azurerm_resource_group.redpanda.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.external_dns.principal_id
  # See https://learn.microsoft.com/en-us/azure/role-based-access-control/troubleshooting?tabs=bicep#symptom---assigning-a-role-to-a-new-principal-sometimes-fails
  principal_type = "ServicePrincipal"
}
