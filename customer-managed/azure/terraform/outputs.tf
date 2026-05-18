output "management_bucket_storage_account_name" {
  description = "Management bucket storage account name"
  value       = module.byovnet.management_bucket_storage_account_name
}

output "management_bucket_storage_container_name" {
  description = "Management bucket storage container name"
  value       = module.byovnet.management_bucket_storage_container_name
}

output "vnet_name" {
  description = "VNet name"
  value       = module.byovnet.vnet_name
}

output "agent_private_subnet_name" {
  description = "Agent private subnet name"
  value       = module.byovnet.agent_private_subnet_name
}

output "rp_0_pods_subnet_name" {
  description = "Redpanda 0 pods subnet name"
  value       = module.byovnet.rp_0_pods_subnet_name
}

output "rp_0_vnet_subnet_name" {
  description = "Redpanda 0 vnet subnet name"
  value       = module.byovnet.rp_0_vnet_subnet_name
}

output "rp_1_pods_subnet_name" {
  description = "Redpanda 1 pods subnet name"
  value       = module.byovnet.rp_1_pods_subnet_name
}

output "rp_1_vnet_subnet_name" {
  description = "Redpanda 1 vnet subnet name"
  value       = module.byovnet.rp_1_vnet_subnet_name
}

output "rp_2_pods_subnet_name" {
  description = "Redpanda 2 pods subnet name"
  value       = module.byovnet.rp_2_pods_subnet_name
}

output "rp_2_vnet_subnet_name" {
  description = "Redpanda 2 vnet subnet name"
  value       = module.byovnet.rp_2_vnet_subnet_name
}

output "rp_connect_pods_subnet_name" {
  description = "Redpanda connect pods subnet name"
  value       = module.byovnet.rp_connect_pods_subnet_name
}

output "rp_connect_vnet_subnet_name" {
  description = "Redpanda connect vnet subnet name"
  value       = module.byovnet.rp_connect_vnet_subnet_name
}

output "kafka_connect_pods_subnet_name" {
  description = "Kafka connect pods subnet name"
  value       = module.byovnet.kafka_connect_pods_subnet_name
}

output "kafka_connect_vnet_subnet_name" {
  description = "Kafka connect vnet subnet name"
  value       = module.byovnet.kafka_connect_vnet_subnet_name
}

output "system_pods_subnet_name" {
  description = "System pods subnet name"
  value       = module.byovnet.system_pods_subnet_name
}

output "system_vnet_subnet_name" {
  description = "System vnet subnet name"
  value       = module.byovnet.system_vnet_subnet_name
}

output "egress_subnet_name" {
  description = "Egress subnet name"
  value       = module.byovnet.egress_subnet_name
}

output "redpanda_resource_group_name" {
  description = "Redpanda resource group name"
  value       = module.byovnet.redpanda_resource_group_name
}

output "storage_resource_group_name" {
  description = "Storage resource group name"
  value       = module.byovnet.storage_resource_group_name
}

output "network_resource_group_name" {
  description = "Network resource group name"
  value       = module.byovnet.network_resource_group_name
}

output "iam_resource_group_name" {
  description = "IAM resource group name"
  value       = module.byovnet.iam_resource_group_name
}

output "agent_user_assigned_identity_name" {
  description = "Agent user assigned identity name"
  value       = module.byovnet.agent_user_assigned_identity_name
}

output "cert_manager_user_assigned_identity_name" {
  description = "Cert manager user assigned identity name"
  value       = module.byovnet.cert_manager_user_assigned_identity_name
}

output "external_dns_user_assigned_identity_name" {
  description = "External DNS user assigned identity name"
  value       = module.byovnet.external_dns_user_assigned_identity_name
}

output "aks_user_assigned_identity_name" {
  description = "AKS user assigned identity name"
  value       = module.byovnet.aks_user_assigned_identity_name
}

output "cluster_user_assigned_identity_name" {
  description = "Redpanda cluster user assigned identity name"
  value       = module.byovnet.cluster_user_assigned_identity_name
}

output "console_user_assigned_identity_name" {
  description = "Redpanda console user assigned identity name"
  value       = module.byovnet.console_user_assigned_identity_name
}

output "kafka_connect_user_assigned_identity_name" {
  description = "Redpanda Kafka Connect user assigned identity name"
  value       = module.byovnet.kafka_connect_user_assigned_identity_name
}

output "redpanda_connect_user_assigned_identity_name" {
  description = "Redpanda Connect user assigned identity name"
  value       = module.byovnet.redpanda_connect_user_assigned_identity_name
}

output "redpanda_connect_api_user_assigned_identity_name" {
  description = "Redpanda Connect API user assigned identity name"
  value       = module.byovnet.redpanda_connect_api_user_assigned_identity_name
}

output "redpanda_operator_user_assigned_identity_name" {
  description = "Redpanda operator user assigned identity name"
  value       = module.byovnet.redpanda_operator_user_assigned_identity_name
}

output "management_key_vault_name" {
  description = "Management key vault name"
  value       = module.byovnet.management_key_vault_name
}

output "console_key_vault_name" {
  description = "Console key vault name"
  value       = module.byovnet.console_key_vault_name
}

output "tiered_storage_account_name" {
  description = "tiered storage account name"
  value       = module.byovnet.tiered_storage_account_name
}

output "tiered_storage_container_name" {
  description = "tiered storage container name"
  value       = module.byovnet.tiered_storage_container_name
}

output "redpanda_security_group_name" {
  description = "Redpanda security group name"
  value       = module.byovnet.redpanda_security_group_name
}

output "resource_groups" {
  description = "Resource groups"
  value       = module.byovnet.resource_groups
}

output "roles" {
  description = "IAM roles"
  value       = module.byovnet.roles
}

output "identities" {
  description = "User assigned identities"
  value       = module.byovnet.identities
}

output "networks" {
  description = "Networks"
  value       = module.byovnet.networks
}

output "security" {
  description = "Security groups"
  value       = module.byovnet.security
}

output "storage" {
  description = "Storage"
  value       = module.byovnet.storage
}

output "vault" {
  description = "Key vault"
  value       = module.byovnet.vault
}
