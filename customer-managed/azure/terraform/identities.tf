resource "azurerm_user_assigned_identity" "redpanda_agent" {
  location            = azurerm_resource_group.iam.location
  name                = "${var.resource_name_prefix}${var.redpanda_agent_identity_name}"
  resource_group_name = azurerm_resource_group.iam.name
}

resource "azurerm_user_assigned_identity" "cert_manager" {
  location            = azurerm_resource_group.iam.location
  name                = "${var.resource_name_prefix}${var.redpanda_cert_manager_identity_name}"
  resource_group_name = azurerm_resource_group.iam.name
}

resource "azurerm_user_assigned_identity" "external_dns" {
  location            = azurerm_resource_group.iam.location
  name                = "${var.resource_name_prefix}${var.redpanda_external_dns_identity_name}"
  resource_group_name = azurerm_resource_group.iam.name
}

resource "azurerm_user_assigned_identity" "redpanda_cluster" {
  location            = azurerm_resource_group.iam.location
  name                = "${var.resource_name_prefix}${var.redpanda_cluster_identity_name}"
  resource_group_name = azurerm_resource_group.iam.name
}

resource "azurerm_user_assigned_identity" "redpanda_console" {
  location            = azurerm_resource_group.iam.location
  name                = "${var.resource_name_prefix}${var.redpanda_console_identity_name}"
  resource_group_name = azurerm_resource_group.iam.name
}
