output "management_bucket_storage_account_name" {
  description = "Management bucket storage account name"
  value       = azurerm_storage_account.management.name
}

output "management_bucket_storage_container_name" {
  description = "Management bucket storage container name"
  value       = azurerm_storage_container.management.name
}

output "vnet_name" {
  description = "VNet name"
  value       = azurerm_virtual_network.redpanda.name
}

output "agent_private_subnet_name" {
  description = "Agent private subnet name"
  value       = azurerm_subnet.private["agent-private"].name
}

output "rp_0_pods_subnet_name" {
  description = "Redpanda 0 pods subnet name"
  value       = azurerm_subnet.private["rp-0-pods"].name
}

output "rp_0_vnet_subnet_name" {
  description = "Redpanda 0 vnet subnet name"
  value       = azurerm_subnet.private["rp-0-vnet"].name
}

output "rp_1_pods_subnet_name" {
  description = "Redpanda 1 pods subnet name"
  value       = azurerm_subnet.private["rp-1-pods"].name
}

output "rp_1_vnet_subnet_name" {
  description = "Redpanda 1 vnet subnet name"
  value       = azurerm_subnet.private["rp-1-vnet"].name
}
output "rp_2_pods_subnet_name" {
  description = "Redpanda 2 pods subnet name"
  value       = azurerm_subnet.private["rp-2-pods"].name
}

output "rp_2_vnet_subnet_name" {
  description = "Redpanda 2 vnet subnet name"
  value       = azurerm_subnet.private["rp-2-vnet"].name
}

output "rp_connect_pods_subnet_name" {
  description = "Redpanda connect pods subnet name"
  value       = azurerm_subnet.private["connect-pod"].name
}

output "rp_connect_vnet_subnet_name" {
  description = "Redpanda connect vnet subnet name"
  value       = azurerm_subnet.private["connect-vnet"].name
}

output "kafka_connect_pods_subnet_name" {
  description = "Kafka connect pods subnet name"
  value       = azurerm_subnet.private["kafka-connect-pod"].name
}

output "kafka_connect_vnet_subnet_name" {
  description = "Kafka connect vnet subnet name"
  value       = azurerm_subnet.private["kafka-connect-vnet"].name
}

output "system_pods_subnet_name" {
  description = "System pods subnet name"
  value       = azurerm_subnet.private["system-pod"].name
}

output "system_vnet_subnet_name" {
  description = "System vnet subnet name"
  value       = azurerm_subnet.private["system-vnet"].name
}

output "egress_subnet_name" {
  description = "Egress subnet name"
  value       = azurerm_subnet.public["agent-public"].name
}


output "redpanda_resource_group_name" {
  description = "Redpanda resource group name"
  value       = azurerm_resource_group.redpanda.name
}

output "storage_resource_group_name" {
  description = "Storage resource group name"
  value       = azurerm_resource_group.storage.name
}

output "network_resource_group_name" {
  description = "Network resource group name"
  value       = azurerm_resource_group.network.name
}

output "iam_resource_group_name" {
  description = "IAM resource group name"
  value       = azurerm_resource_group.iam.name
}

output "agent_user_assigned_identity_name" {
  description = "Agent user assigned identity name"
  value       = azurerm_user_assigned_identity.redpanda_agent.name
}

output "cert_manager_user_assigned_identity_name" {
  description = "Cert manager user assigned identity name"
  value       = azurerm_user_assigned_identity.cert_manager.name
}

output "external_dns_user_assigned_identity_name" {
  description = "External DNS user assigned identity name"
  value       = azurerm_user_assigned_identity.external_dns.name
}

output "aks_user_assigned_identity_name" {
  description = "AKS user assigned identity name"
  value       = azurerm_user_assigned_identity.aks.name
}

output "cluster_user_assigned_identity_name" {
  description = "Redpanda cluster user assigned identity name"
  value       = azurerm_user_assigned_identity.redpanda_cluster.name
}

output "console_user_assigned_identity_name" {
  description = "Redpanda console user assigned identity name"
  value       = azurerm_user_assigned_identity.redpanda_console.name
}

output "kafka_connect_user_assigned_identity_name" {
  description = "Redpanda Kafka Connect user assigned identity name"
  value       = azurerm_user_assigned_identity.kafka_connect.name
}

output "management_key_vault_name" {
  description = "Management key vault name"
  value       = var.redpanda_management_key_vault_name != "" ? azurerm_key_vault.vault[0].name : ""
}

output "console_key_vault_name" {
  description = "Console key vault name"
  value       = var.redpanda_console_key_vault_name != "" ? azurerm_key_vault.console[0].name : ""
}

output "tiered_storage_account_name" {
  description = "tiered storage account name"
  value       = azurerm_storage_account.tiered_storage.name
}

output "tiered_storage_container_name" {
  description = "tiered storage container name"
  value       = azurerm_storage_container.tiered_storage.name
}

output "redpanda_security_group_name" {
  description = "Redpanda security group name"
  value       = azurerm_network_security_group.redpanda_cluster.name
}

output "resource_groups" {
  description = "Resource groups"
  value = jsonencode({
    "redpanda" : {
      "name" : azurerm_resource_group.redpanda.name,
      "id" : azurerm_resource_group.redpanda.id
    },
    "storage" : {
      "name" : azurerm_resource_group.storage.name,
      "id" : azurerm_resource_group.storage.id
    },
    "network" : {
      "name" : azurerm_resource_group.network.name,
      "id" : azurerm_resource_group.network.id
    },
    "iam" : {
      "name" : azurerm_resource_group.iam.name,
      "id" : azurerm_resource_group.iam.id
    }
  })
}

output "roles" {
  description = "IAM roles"
  value = jsonencode({
    "agent" : azurerm_role_definition.redpanda_agent.id,
    "console" : azurerm_role_definition.redpanda_console.id,
    "private-link" : azurerm_role_definition.redpanda_private_link.id
  })
}

output "identities" {
  description = "User assigned identities"
  value = jsonencode({
    "agent" : azurerm_user_assigned_identity.redpanda_agent.id,
    "cert-manager" : azurerm_user_assigned_identity.cert_manager.id,
    "external-dns" : azurerm_user_assigned_identity.external_dns.id,
    "aks" : azurerm_user_assigned_identity.aks.id,
    "redpanda-cluster" : azurerm_user_assigned_identity.redpanda_cluster.id,
    "redpanda-console" : azurerm_user_assigned_identity.redpanda_console.id
  })
}

output "networks" {
  description = "Networks"
  value = jsonencode({
    "vnet" : {
      "name" : azurerm_virtual_network.redpanda.name,
      "resource_group" : azurerm_virtual_network.redpanda.resource_group_name,
      "address_space" : join(",", azurerm_virtual_network.redpanda.address_space)
    },
    "private-subnets" : {
      for k, v in azurerm_subnet.private : k => {
        "id" : v.id,
        "address_prefixes" : join(",", v.address_prefixes)
      }
    },
    "egress-subnets" : {
      for k, v in azurerm_subnet.public : k => {
        "id" : v.id,
        "address_prefixes" : join(",", v.address_prefixes)
      }
    }
    "subnet-cidrs-aks" : var.reserved_subnet_cidrs
  })
}

output "security" {
  description = "Security groups"
  value = jsonencode({
    "redpanda-cluster" : azurerm_network_security_group.redpanda_cluster.id
  })
}

output "storage" {
  description = "Storage"
  value = jsonencode({
    "management" : {
      "storage-account-id" : azurerm_storage_account.management.id,
      "bucket" : azurerm_storage_container.management.id
    },
    "tiered" : {
      "storage-account-id" : azurerm_storage_account.tiered_storage.id,
      "bucket" : azurerm_storage_container.tiered_storage.id
    }
  })
}

output "vault" {
  description = "Key vault"
  value = jsonencode({
    "redpanda-cluster" : var.redpanda_console_key_vault_name != "" ? azurerm_key_vault.vault[0].id : ""
    "redpanda-console" : var.redpanda_console_key_vault_name != "" ? azurerm_key_vault.console[0].id : ""
  })
}
