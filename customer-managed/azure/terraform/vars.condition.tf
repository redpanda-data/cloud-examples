variable "create_role_assignment" {
  type        = bool
  default     = true
  description = <<-HELP
    Whether to create role assigments.
  HELP
}

variable "grant_caller_management_storage_access" {
  type        = bool
  default     = false
  description = <<-HELP
    If true, grants the caller (the identity running Terraform) the Storage Blob Data
    Contributor role on the management storage account. Required when running Terraform
    as a user or service principal, since the storage account has shared access keys
    disabled and only allows Azure AD authentication.
  HELP
}

variable "create_nat" {
  type        = bool
  default     = true
  description = <<-HELP
  Whether to create NAT gateway and its assoications
  HELP
}

variable "hub_vnet_id" {
  type        = string
  default     = ""
  description = <<-HELP
    Resource ID of an existing hub VNet to peer with for gateway-transit egress.
    Leave empty to have Terraform create a hub VNet (requires hub_firewall_ip to
    be set). If provided, Terraform skips hub VNet creation and peers directly to
    this VNet.
  HELP
}

variable "hub_vnet_address_space" {
  type        = list(string)
  default     = ["10.255.0.0/16"]
  description = <<-HELP
    Address space for the hub VNet created when hub_vnet_id is empty and
    hub_firewall_ip is set. Must not overlap with vnet_addresses.
  HELP
}

variable "hub_firewall_subnet_cidr" {
  type        = string
  default     = "10.255.0.0/26"
  description = <<-HELP
    CIDR for the AzureFirewallSubnet created inside the managed hub VNet.
    Must be within hub_vnet_address_space and at least /26 (Azure requirement).
    Only used when hub_vnet_id is empty and hub_firewall_ip is set.
  HELP
}

variable "hub_firewall_ip" {
  type        = string
  default     = ""
  description = <<-HELP
    Private IP of an existing hub Azure Firewall or NVA. Setting this enables
    gateway egress mode. Leave empty when create_hub_firewall = true — the IP
    will be derived from the Terraform-created firewall automatically.
  HELP
}

variable "create_hub_firewall" {
  type        = bool
  default     = false
  description = <<-HELP
    When true, Terraform creates an Azure Firewall (Standard tier) with a
    permissive allow-all egress policy inside the managed hub VNet. Enables
    gateway egress mode without requiring hub_firewall_ip as an input.
    Requires hub_vnet_id to be empty (hub VNet must also be managed here).
    Note: Azure Firewall costs ~$1.25/hr; destroy when the PoC is done.
  HELP
}

variable "create_vnet_peering" {
  type        = bool
  default     = true
  description = <<-HELP
    Controls whether Terraform creates the spoke-side VNet peering. Set to false
    only if the customer will manage peering on both sides themselves.
  HELP
}

variable "use_remote_gateway" {
  type        = bool
  default     = false
  description = <<-HELP
    Sets use_remote_gateways = true on the spoke-side peering, enabling BGP
    route propagation through the hub's VPN/ExpressRoute gateway. Requires the
    hub VNet to have a gateway with allow_gateway_transit = true. Leave false
    for pure firewall-based egress without a VPN gateway in the hub.
  HELP
}

