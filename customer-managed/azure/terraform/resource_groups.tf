locals {
  redpanda_resource_group_name         = "${var.resource_group_name_prefix}${var.redpanda_resource_group_name}"
  redpanda_storage_resource_group_name = "${var.resource_group_name_prefix}${var.redpanda_storage_resource_group_name}"
  redpanda_network_resource_group_name = "${var.resource_group_name_prefix}${var.redpanda_network_resource_group_name}"
  redpanda_iam_resource_group_name     = "${var.resource_group_name_prefix}${var.redpanda_iam_resource_group_name}"

  resource_group_names = distinct([local.redpanda_resource_group_name, local.redpanda_storage_resource_group_name, local.redpanda_network_resource_group_name, local.redpanda_iam_resource_group_name])

  resource_groups                 = { for rg in(var.create_resource_groups ? azurerm_resource_group.all : data.azurerm_resource_group.all) : rg.name => rg }
  redpanda_resource_group         = local.resource_groups[local.redpanda_resource_group_name]
  redpanda_storage_resource_group = local.resource_groups[local.redpanda_storage_resource_group_name]
  redpanda_network_resource_group = local.resource_groups[local.redpanda_network_resource_group_name]
  redpanda_iam_resource_group     = local.resource_groups[local.redpanda_iam_resource_group_name]

  resource_group_ids = [for rg in azurerm_resource_group.all : rg.id]
}

resource "azurerm_resource_group" "all" {
  for_each = var.create_resource_groups ? toset(local.resource_group_names) : []

  name     = each.value
  location = var.region

  tags = var.tags
}

data "azurerm_resource_group" "all" {
  for_each = var.create_resource_groups ? [] : toset(local.resource_group_names)
  name     = each.value
}
