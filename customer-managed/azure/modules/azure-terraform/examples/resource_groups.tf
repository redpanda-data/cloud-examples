

resource "azurerm_resource_group" "redpanda" {
  name     = "${var.resource_name_prefix}${var.redpanda_resource_group_name}"
  location = var.region

  tags = var.tags
}

resource "azurerm_resource_group" "storage" {
  name     = "${var.resource_name_prefix}${var.redpanda_storage_resource_group_name}"
  location = var.region

  tags = var.tags
}

resource "azurerm_resource_group" "network" {
  name     = "${var.resource_name_prefix}${var.redpanda_network_resource_group_name}"
  location = var.region

  tags = var.tags
}

resource "azurerm_resource_group" "iam" {
  name     = "${var.resource_name_prefix}${var.redpanda_iam_resource_group_name}"
  location = var.region

  tags = var.tags
}

