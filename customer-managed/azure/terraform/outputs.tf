output "resource_groups" {
  description = "Resource groups"
  value = {
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
  }
}

output "roles" {
  description = "IAM roles"
  value = {
    "agent" : azurerm_role_definition.redpanda_agent.id,
    "console" : azurerm_role_definition.redpanda_console.id,
    "private-link" : azurerm_role_definition.redpanda_private_link.id
  }
}

output "identities" {
  description = "User assigned identities"
  value = {
    "agent" : azurerm_user_assigned_identity.redpanda_agent.id,
    "cert-manager" : azurerm_user_assigned_identity.cert_manager.id,
    "external-dns" : azurerm_user_assigned_identity.external_dns.id,
    "aks" : azurerm_user_assigned_identity.aks.id,
    "redpanda-cluster" : azurerm_user_assigned_identity.redpanda_cluster.id,
    "redpanda-console" : azurerm_user_assigned_identity.redpanda_console.id
  }
}

output "networks" {
  description = "Networks"
  value = {
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
  }
}

output "security" {
  description = "Security groups"
  value = {
    "redpanda-cluster" : azurerm_network_security_group.redpanda_cluster.id
  }
}

output "storage" {
  description = "Storage"
  value = {
    "management" : {
      "storage-account-id" : azurerm_storage_account.management.id,
      "bucket" : azurerm_storage_container.management.id
    },
    "tiered" : {
      "storage-account-id" : azurerm_storage_account.tiered_storage.id,
      "bucket" : azurerm_storage_container.tiered_storage.id
    }
  }
}

output "vault" {
  description = "Key vault"
  value = {
    "redpanda-cluster" : var.redpanda_console_key_vault_name != "" ? azurerm_key_vault.vault[0].id : ""
    "redpanda-console" : var.redpanda_console_key_vault_name != "" ? azurerm_key_vault.console[0].id : ""
  }
}
