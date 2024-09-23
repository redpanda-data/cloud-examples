locals {
  vnet      = data.azurerm_virtual_network.redpanda
  vnet_name = local.vnet.name
}
resource "azurerm_virtual_network" "redpanda" {
  count               = var.vnet_name == "" ? 1 : 0
  name                = "${var.resource_name_prefix}rp-vnet"
  location            = var.region
  resource_group_name = azurerm_resource_group.network.name
  address_space       = var.vnet_addresses

  tags = var.tags
}

data "azurerm_virtual_network" "redpanda" {
  name                = var.vnet_name == "" ? azurerm_virtual_network.redpanda[0].name : var.vnet_name
  resource_group_name = azurerm_resource_group.network.name
}

resource "azurerm_subnet" "private" {
  for_each = var.private_subnets

  name                 = "${var.resource_name_prefix}${each.value.name}"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = local.vnet_name
  address_prefixes     = [each.value.cidr]

  # Use Azure's internal network to reach out to the following Azure services
  service_endpoints = [
    "Microsoft.Storage.Global",
    "Microsoft.AzureActiveDirectory",
    "Microsoft.KeyVault"
  ]

  lifecycle {
    # AKS automatically configures subnet delegations when the subnets are assigned
    # to node pools. To prevent undoing the delegations when network provisioning
    # re-runs, we ignore any changes on them.
    ignore_changes = [delegation]
  }
}

resource "azurerm_subnet" "public" {
  for_each = var.egress_subnets

  name                 = "${var.resource_name_prefix}${each.value.name}"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = local.vnet_name
  address_prefixes     = [each.value.cidr]

  # Use Azure's internal network to reach out to the following Azure services
  service_endpoints = [
    "Microsoft.Storage.Global",
    "Microsoft.AzureActiveDirectory",
    "Microsoft.KeyVault",
  ]
}
