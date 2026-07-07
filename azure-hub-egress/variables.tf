# ---------------------------------------------------------------------------
# Authentication
# ---------------------------------------------------------------------------

variable "client_id" {
  type        = string
  default     = ""
  description = "Azure service principal client ID. Leave empty when using CLI or MSI auth."
}

variable "client_secret" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Azure service principal client secret. Leave empty when using CLI or MSI auth."
}

variable "tenant_id" {
  type        = string
  default     = ""
  description = "Azure tenant ID."
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID where hub resources will be created."
}

variable "use_cli" {
  type        = bool
  default     = true
  description = "Use Azure CLI for authentication instead of service principal credentials."
}

variable "use_msi" {
  type        = bool
  default     = false
  description = "Use Managed Service Identity (MSI) for authentication."
}

variable "use_oidc" {
  type        = bool
  default     = false
  description = "Use OIDC (Workload Identity Federation) for authentication."
}

# ---------------------------------------------------------------------------
# Core
# ---------------------------------------------------------------------------

variable "location" {
  type        = string
  description = "Azure region for all hub resources (e.g. \"eastus2\", \"westeurope\")."
}

variable "resource_group_name" {
  type        = string
  default     = "hub-egress-rg"
  description = "Name of the resource group to create for hub resources."
}

variable "common_prefix" {
  type        = string
  default     = "hub"
  description = "Prefix applied to all resource names (VNet, firewall, public IP, etc.)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources."
}

# ---------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------

variable "hub_vnet_address_space" {
  type        = list(string)
  default     = ["10.255.0.0/16"]
  description = <<-HELP
    Address space for the hub VNet. Must not overlap with any Redpanda cluster
    VNet address space — VNet peering is rejected on CIDR overlap.
    10.255.0.0/16 avoids common enterprise ranges.
  HELP
}

variable "hub_firewall_subnet_cidr" {
  type        = string
  default     = "10.255.0.0/26"
  description = <<-HELP
    CIDR for the AzureFirewallSubnet within the hub VNet. Azure requires the
    subnet to be named exactly "AzureFirewallSubnet" and be at least /26.
    Must fall within hub_vnet_address_space.
  HELP
}

# ---------------------------------------------------------------------------
# Peering — hub → Redpanda spokes
# ---------------------------------------------------------------------------

variable "redpanda_vnets" {
  type = map(object({
    vnet_id = string
  }))
  default = {}
  description = <<-HELP
    Map of Redpanda BYOC cluster VNets to peer with the hub (hub → spoke direction).
    The map key is used as the peering name suffix.

    The Redpanda VNet is created during BYOC cluster provisioning. Add entries
    after the cluster network exists and re-apply this module.

    vnet_id is the full Azure resource ID of the Redpanda (spoke) VNet, e.g.:
      /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{name}
    Retrieve it from the Redpanda Cloud console or via:
      az network vnet show --name <vnet> --resource-group <rg> --query id -o tsv

    Example:
      redpanda_vnets = {
        "cluster-a" = {
          vnet_id = "/subscriptions/00000000-.../resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/rp-vnet"
        }
      }
  HELP
}
