module "byovnet" {
  source  = "redpanda-data/redpanda-byovnet/azure"
  version = "~> 1.1"

  region                     = var.region
  zones                      = var.zones
  tags                       = var.tags
  resource_name_prefix       = var.resource_name_prefix
  resource_group_name_prefix = var.resource_group_name_prefix

  create_role_assignment                 = var.create_role_assignment
  grant_caller_management_storage_access = var.grant_caller_management_storage_access
  create_nat                             = var.create_nat

  # Only azure_tenant_id is consumed inside the module (key vault tenancy);
  # the other azure_* vars configure the root provider in providers.tf.
  azure_tenant_id = var.azure_tenant_id

  redpanda_agent_role_name          = var.redpanda_agent_role_name
  redpanda_console_role_name        = var.redpanda_console_role_name
  redpanda_private_link_role_name   = var.redpanda_private_link_role_name
  kafka_connect_role_name           = var.kafka_connect_role_name
  redpanda_connect_role_name        = var.redpanda_connect_role_name
  redpanda_connect_api_role_name    = var.redpanda_connect_api_role_name
  redpanda_secrets_reader_role_name = var.redpanda_secrets_reader_role_name

  create_resource_groups               = var.create_resource_groups
  redpanda_resource_group_name         = var.redpanda_resource_group_name
  redpanda_storage_resource_group_name = var.redpanda_storage_resource_group_name
  redpanda_network_resource_group_name = var.redpanda_network_resource_group_name
  redpanda_iam_resource_group_name     = var.redpanda_iam_resource_group_name

  redpanda_agent_identity_name        = var.redpanda_agent_identity_name
  redpanda_cert_manager_identity_name = var.redpanda_cert_manager_identity_name
  redpanda_external_dns_identity_name = var.redpanda_external_dns_identity_name
  redpanda_cluster_identity_name      = var.redpanda_cluster_identity_name
  aks_identity_name                   = var.aks_identity_name
  redpanda_console_identity_name      = var.redpanda_console_identity_name
  kafka_connect_identity_name         = var.kafka_connect_identity_name
  redpanda_connect_identity_name      = var.redpanda_connect_identity_name
  redpanda_connect_api_identity_name  = var.redpanda_connect_api_identity_name
  redpanda_operator_identity_name     = var.redpanda_operator_identity_name

  redpanda_management_storage_account_name   = var.redpanda_management_storage_account_name
  redpanda_management_storage_container_name = var.redpanda_management_storage_container_name
  redpanda_tiered_storage_account_name       = var.redpanda_tiered_storage_account_name
  redpanda_tiered_storage_container_name     = var.redpanda_tiered_storage_container_name

  redpanda_management_key_vault_name = var.redpanda_management_key_vault_name
  redpanda_console_key_vault_name    = var.redpanda_console_key_vault_name

  vnet_name             = var.vnet_name
  vnet_addresses        = var.vnet_addresses
  private_subnets       = var.private_subnets
  egress_subnets        = var.egress_subnets
  reserved_subnet_cidrs = var.reserved_subnet_cidrs

  redpanda_security_group_name = var.redpanda_security_group_name
}

# State migration for deployments that pre-date the module refactor.
# Every resource previously declared in this directory is now created by
# module.byovnet; these `moved` blocks rewrite existing state addresses so
# `terraform apply` is a no-op instead of a destroy/recreate.

moved {
  from = azurerm_key_vault.console
  to   = module.byovnet.azurerm_key_vault.console
}

moved {
  from = azurerm_key_vault.vault
  to   = module.byovnet.azurerm_key_vault.vault
}

moved {
  from = azurerm_nat_gateway.redpanda
  to   = module.byovnet.azurerm_nat_gateway.redpanda
}

moved {
  from = azurerm_nat_gateway_public_ip_prefix_association.redpanda
  to   = module.byovnet.azurerm_nat_gateway_public_ip_prefix_association.redpanda
}

moved {
  from = azurerm_network_security_group.redpanda_cluster
  to   = module.byovnet.azurerm_network_security_group.redpanda_cluster
}

moved {
  from = azurerm_network_security_group.redpanda_connectors
  to   = module.byovnet.azurerm_network_security_group.redpanda_connectors
}

moved {
  from = azurerm_network_security_rule.allow_inbound_to_redpanda_brokers_nodeport
  to   = module.byovnet.azurerm_network_security_rule.allow_inbound_to_redpanda_brokers_nodeport
}

moved {
  from = azurerm_public_ip_prefix.redpanda
  to   = module.byovnet.azurerm_public_ip_prefix.redpanda
}

moved {
  from = azurerm_resource_group.all
  to   = module.byovnet.azurerm_resource_group.all
}

moved {
  from = azurerm_role_assignment.agent
  to   = module.byovnet.azurerm_role_assignment.agent
}

moved {
  from = azurerm_role_assignment.aks_network_contributor
  to   = module.byovnet.azurerm_role_assignment.aks_network_contributor
}

moved {
  from = azurerm_role_assignment.assign_identity_storage_blob_data_contributor
  to   = module.byovnet.azurerm_role_assignment.assign_identity_storage_blob_data_contributor
}

moved {
  from = azurerm_role_assignment.caller_management_storage_blob_data_contributor
  to   = module.byovnet.azurerm_role_assignment.caller_management_storage_blob_data_contributor
}

moved {
  from = azurerm_role_assignment.cert_manager
  to   = module.byovnet.azurerm_role_assignment.cert_manager
}

moved {
  from = azurerm_role_assignment.external_dns_rgreader
  to   = module.byovnet.azurerm_role_assignment.external_dns_rgreader
}

moved {
  from = azurerm_role_assignment.external_dns_zone_contributor
  to   = module.byovnet.azurerm_role_assignment.external_dns_zone_contributor
}

moved {
  from = azurerm_role_assignment.kafka_connect
  to   = module.byovnet.azurerm_role_assignment.kafka_connect
}

moved {
  from = azurerm_role_assignment.redpanda_cluster
  to   = module.byovnet.azurerm_role_assignment.redpanda_cluster
}

moved {
  from = azurerm_role_assignment.redpanda_cluster_secrets_reader
  to   = module.byovnet.azurerm_role_assignment.redpanda_cluster_secrets_reader
}

moved {
  from = azurerm_role_assignment.redpanda_connect
  to   = module.byovnet.azurerm_role_assignment.redpanda_connect
}

moved {
  from = azurerm_role_assignment.redpanda_connect_api
  to   = module.byovnet.azurerm_role_assignment.redpanda_connect_api
}

moved {
  from = azurerm_role_assignment.redpanda_console
  to   = module.byovnet.azurerm_role_assignment.redpanda_console
}

moved {
  from = azurerm_role_assignment.redpanda_operator_secrets_reader
  to   = module.byovnet.azurerm_role_assignment.redpanda_operator_secrets_reader
}

moved {
  from = azurerm_role_assignment.redpanda_private_link
  to   = module.byovnet.azurerm_role_assignment.redpanda_private_link
}

moved {
  from = azurerm_role_assignment.vault_secrets_officer
  to   = module.byovnet.azurerm_role_assignment.vault_secrets_officer
}

moved {
  from = azurerm_role_definition.kafka_connect
  to   = module.byovnet.azurerm_role_definition.kafka_connect
}

moved {
  from = azurerm_role_definition.redpanda_agent
  to   = module.byovnet.azurerm_role_definition.redpanda_agent
}

moved {
  from = azurerm_role_definition.redpanda_connect
  to   = module.byovnet.azurerm_role_definition.redpanda_connect
}

moved {
  from = azurerm_role_definition.redpanda_connect_api
  to   = module.byovnet.azurerm_role_definition.redpanda_connect_api
}

moved {
  from = azurerm_role_definition.redpanda_console
  to   = module.byovnet.azurerm_role_definition.redpanda_console
}

moved {
  from = azurerm_role_definition.redpanda_private_link
  to   = module.byovnet.azurerm_role_definition.redpanda_private_link
}

moved {
  from = azurerm_role_definition.redpanda_secrets_reader
  to   = module.byovnet.azurerm_role_definition.redpanda_secrets_reader
}

moved {
  from = azurerm_storage_account.management
  to   = module.byovnet.azurerm_storage_account.management
}

moved {
  from = azurerm_storage_account.tiered_storage
  to   = module.byovnet.azurerm_storage_account.tiered_storage
}

moved {
  from = azurerm_storage_account_network_rules.redpanda_cloud_storage
  to   = module.byovnet.azurerm_storage_account_network_rules.redpanda_cloud_storage
}

moved {
  from = azurerm_storage_container.management
  to   = module.byovnet.azurerm_storage_container.management
}

moved {
  from = azurerm_storage_container.tiered_storage
  to   = module.byovnet.azurerm_storage_container.tiered_storage
}

moved {
  from = azurerm_subnet.private
  to   = module.byovnet.azurerm_subnet.private
}

moved {
  from = azurerm_subnet.public
  to   = module.byovnet.azurerm_subnet.public
}

moved {
  from = azurerm_subnet_nat_gateway_association.redpanda
  to   = module.byovnet.azurerm_subnet_nat_gateway_association.redpanda
}

moved {
  from = azurerm_user_assigned_identity.aks
  to   = module.byovnet.azurerm_user_assigned_identity.aks
}

moved {
  from = azurerm_user_assigned_identity.cert_manager
  to   = module.byovnet.azurerm_user_assigned_identity.cert_manager
}

moved {
  from = azurerm_user_assigned_identity.external_dns
  to   = module.byovnet.azurerm_user_assigned_identity.external_dns
}

moved {
  from = azurerm_user_assigned_identity.kafka_connect
  to   = module.byovnet.azurerm_user_assigned_identity.kafka_connect
}

moved {
  from = azurerm_user_assigned_identity.redpanda_agent
  to   = module.byovnet.azurerm_user_assigned_identity.redpanda_agent
}

moved {
  from = azurerm_user_assigned_identity.redpanda_cluster
  to   = module.byovnet.azurerm_user_assigned_identity.redpanda_cluster
}

moved {
  from = azurerm_user_assigned_identity.redpanda_connect
  to   = module.byovnet.azurerm_user_assigned_identity.redpanda_connect
}

moved {
  from = azurerm_user_assigned_identity.redpanda_connect_api
  to   = module.byovnet.azurerm_user_assigned_identity.redpanda_connect_api
}

moved {
  from = azurerm_user_assigned_identity.redpanda_console
  to   = module.byovnet.azurerm_user_assigned_identity.redpanda_console
}

moved {
  from = azurerm_user_assigned_identity.redpanda_operator
  to   = module.byovnet.azurerm_user_assigned_identity.redpanda_operator
}

moved {
  from = azurerm_virtual_network.redpanda
  to   = module.byovnet.azurerm_virtual_network.redpanda
}
