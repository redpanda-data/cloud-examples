###########################################################################
# IAM vars: resource groups and roles
###########################################################################
variable "redpanda_resource_group_name" {
  type        = string
  default     = "redpanda-rg"
  description = <<-HELP
    The name of the resource group to place Redpanda resources.
  HELP
}

variable "redpanda_storage_resource_group_name" {
  type        = string
  default     = "tiered-storage-rg"
  description = <<-HELP
    The name of the resource group to place Redpanda storage resources.
  HELP
}
variable "redpanda_network_resource_group_name" {
  type        = string
  default     = "network-rg"
  description = <<-HELP
    The name of the resource group to place Redpanda network resources.
  HELP
}

variable "redpanda_iam_resource_group_name" {
  type        = string
  default     = "iam-rg"
  description = <<-HELP
    The name of the resource group to place Redpanda IAM resources.
  HELP
}

variable "redpanda_agent_role_name" {
  type        = string
  default     = "agent-role"
  description = <<-HELP
    The role name of Redpanda agent.
  HELP
}

variable "redpanda_console_role_name" {
  type        = string
  default     = "console-role"
  description = <<-HELP
    The role name of Redpanda Console.
  HELP
}

variable "redpanda_private_link_role_name" {
  type        = string
  default     = "private-link-role"
  description = <<-HELP
    The role name of Redpanda private link.
  HELP
}

variable "redpanda_agent_identity_name" {
  type        = string
  default     = "agent-uai"
  description = <<-HELP
    The name of user assigned identity for Redpanda agent.
  HELP
}

variable "redpanda_cert_manager_identity_name" {
  type        = string
  default     = "cert_manager-uai"
  description = <<-HELP
    The name of user assigned identity for cert-manager.
  HELP
}


variable "redpanda_external_dns_identity_name" {
  type        = string
  default     = "external_dns-uai"
  description = <<-HELP
    The name of user assigned identity for external-dns.
  HELP
}

variable "redpanda_cluster_identity_name" {
  type        = string
  default     = "cluster-uai"
  description = <<-HELP
    The name of user assigned identity for Redpanda cluster.
  HELP
}

variable "aks_identity_name" {
  type        = string
  default     = "aks-uai"
  description = <<-HELP
    The name of user assigned identity for AKS.
  HELP
}

variable "redpanda_console_identity_name" {
  type        = string
  default     = "console-uai"
  description = <<-HELP
    The name of user assigned identity for Redpanda Console.
  HELP
}

###########################################################################
# Storage vars: resource groups and roles
###########################################################################
variable "redpanda_management_storage_account_name" {
  type        = string
  default     = "management"
  description = <<-HELP
    Azure Blob Storage account name for Redpanda management storage.
  HELP
}

variable "redpanda_management_storage_container_name" {
  type        = string
  default     = "management"
  description = <<-HELP
  Name of the storage container for Redpanda management storage
  HELP
}

variable "redpanda_tiered_storage_account_name" {
  type        = string
  default     = "tieredstorage"
  description = <<-HELP
    Azure Blob Storage account name for Redpanda tiered storage.
  HELP
}

variable "redpanda_tiered_storage_container_name" {
  type        = string
  default     = "tieredstorage"
  description = <<-HELP
  Name of the storage container for Redpanda tiered storage
  HELP
}

variable "redpanda_management_key_vault_name" {
  type        = string
  default     = "redpandavault"
  description = <<-HELP
  The name of key vault for Redpanda management
  HELP
}

variable "redpanda_console_key_vault_name" {
  type        = string
  default     = "consolevault"
  description = <<-HELP
  The name of key vault for Redpanda Console
  HELP
}

###########################################################################
# Network vars: vnet, subnets
###########################################################################
variable "vnet_name" {
  type        = string
  default     = "rp-vnet"
  description = <<-HELP
  The name of the network to be created.
  HELP
}

variable "vnet_addresses" {
  type        = list(string)
  default     = ["10.0.0.0/20"]
  description = <<-HELP
  The list of IP address prefixes used by vnet.
  HELP
}

variable "private_subnets" {
  type = map(map(string))
  default = {
    "agent-private" : {
      "cidr" : "10.0.2.0/24",
      "name" : "snet-agent-private"
    },
    "rp-0-pods" : {
      "cidr" : "10.0.6.0/24",
      "name" : "snet-rp-0-pods"
    },
    "rp-0-vnet" : {
      "cidr" : "10.0.5.0/24",
      "name" : "snet-rp-0-vnet"
    },
    "rp-1-pods" : {
      "cidr" : "10.0.8.0/24",
      "name" : "snet-rp-1-pods"
    },
    "rp-1-vnet" : {
      "cidr" : "10.0.7.0/24",
      "name" : "snet-rp-1-vnet"
    },
    "rp-2-pods" : {
      "cidr" : "10.0.10.0/24",
      "name" : "snet-rp-2-pods"
    },
    "rp-2-vnet" : {
      "cidr" : "10.0.9.0/24",
      "name" : "snet-rp-2-vnet"
    },
    "system-pod" : {
      "cidr" : "10.0.4.0/24",
      "name" : "snet-system-pod"
    },
    "system-vnet" : {
      "cidr" : "10.0.3.0/24",
      "name" : "snet-system-vnet"
    }
  }
  description = <<-HELP
    A list of CIDR ranges to use for the *private* subnets
  HELP
}

variable "egress_subnets" {
  type = map(map(string))
  default = {
    "agent-public" : {
      "cidr" : "10.0.1.0/24",
      "name" : "snet-agent-public"
    }
  }
  description = <<-HELP
    A list of CIDR ranges to use for the *egress* subnets
  HELP
}

variable "reserved_subnet_cidrs" {
  type = map(string)
  default = {
    "k8s-service" : "10.0.11.0/24"
  }
  description = <<-HELP
    Reserved CIDRs for AKS
  HELP
}

variable "redpanda_security_group_name" {
  type        = string
  default     = "redpanda-nsg"
  description = <<-HELP
    The name of Redpanda cluster security group
  HELP
}
