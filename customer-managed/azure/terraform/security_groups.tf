locals {
  rfc1918_prefixes = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  rfc6598_prefixes = ["100.64.0.0/10"]
}

resource "azurerm_network_security_group" "redpanda_cluster" {
  name                = "${var.resource_name_prefix}${var.redpanda_security_group_name}"
  location            = var.region
  resource_group_name = local.redpanda_network_resource_group_name

  tags = var.tags

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_network_security_group" "redpanda_connectors" {
  name                = "${var.resource_name_prefix}nsg-${var.region}-connectors"
  location            = var.region
  resource_group_name = local.redpanda_network_resource_group_name

  tags = var.tags

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_network_security_rule" "allow_inbound_to_redpanda_brokers_nodeport" {
  name                         = "${var.resource_name_prefix}sgr-brokers-inbound"
  description                  = <<-HELP
  Allow traffic sent to Redpanda broker node ports.
  HELP
  priority                     = 101
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_ranges      = ["30644", "30092", "30082", "30081"]
  source_address_prefixes      = concat(local.rfc1918_prefixes, local.rfc6598_prefixes)
  destination_address_prefixes = ["0.0.0.0/0"]
  resource_group_name          = local.redpanda_network_resource_group_name
  network_security_group_name  = azurerm_network_security_group.redpanda_cluster.name
}

resource "azurerm_storage_account_network_rules" "redpanda_cloud_storage" {
  storage_account_id = azurerm_storage_account.tiered_storage.id

  default_action = "Allow"
  bypass         = ["Metrics", "Logging", "AzureServices"]

  # If private link access is configured by organizational Azure policies,
  # we don't want to remove it with our periodic reconciliation.
  lifecycle {
    ignore_changes = [private_link_access]
  }
}
