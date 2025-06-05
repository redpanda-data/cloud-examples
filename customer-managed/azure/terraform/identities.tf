resource "azurerm_user_assigned_identity" "redpanda_agent" {
  location            = var.region
  name                = "${var.resource_name_prefix}${var.redpanda_agent_identity_name}"
  resource_group_name = local.redpanda_iam_resource_group_name

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_user_assigned_identity" "cert_manager" {
  location            = var.region
  name                = "${var.resource_name_prefix}${var.redpanda_cert_manager_identity_name}"
  resource_group_name = local.redpanda_iam_resource_group_name

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_user_assigned_identity" "external_dns" {
  location            = var.region
  name                = "${var.resource_name_prefix}${var.redpanda_external_dns_identity_name}"
  resource_group_name = local.redpanda_iam_resource_group_name

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_user_assigned_identity" "redpanda_cluster" {
  location            = var.region
  name                = "${var.resource_name_prefix}${var.redpanda_cluster_identity_name}"
  resource_group_name = local.redpanda_iam_resource_group_name

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_user_assigned_identity" "aks" {
  location            = var.region
  name                = "${var.resource_name_prefix}${var.aks_identity_name}"
  resource_group_name = local.redpanda_iam_resource_group_name

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_user_assigned_identity" "redpanda_console" {
  location            = var.region
  name                = "${var.resource_name_prefix}${var.redpanda_console_identity_name}"
  resource_group_name = local.redpanda_iam_resource_group_name

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_user_assigned_identity" "kafka_connect" {
  location            = var.region
  name                = "${var.resource_name_prefix}${var.kafka_connect_identity_name}"
  resource_group_name = local.redpanda_iam_resource_group_name

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_user_assigned_identity" "redpanda_connect" {
  location            = var.region
  name                = "${var.resource_name_prefix}${var.redpanda_connect_identity_name}"
  resource_group_name = local.redpanda_iam_resource_group_name

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_user_assigned_identity" "redpanda_connect_api" {
  location            = var.region
  name                = "${var.resource_name_prefix}${var.redpanda_connect_api_identity_name}"
  resource_group_name = local.redpanda_iam_resource_group_name

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_user_assigned_identity" "redpanda_operator" {
  location            = var.region
  name                = "${var.resource_name_prefix}${var.redpanda_operator_identity_name}"
  resource_group_name = local.redpanda_iam_resource_group_name

  depends_on = [azurerm_resource_group.all]
}
