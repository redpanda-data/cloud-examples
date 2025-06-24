locals {
  create_nat = var.create_nat ? 1 : 0
  // zone ids used for resources bound to the NAT gateways
  natg_zone_ids = [
    for m in data.azurerm_location.redpanda.zone_mappings :
    m.logical_zone if contains(slice(var.zones, 0, 1), m.physical_zone)
  ]
}

resource "azurerm_nat_gateway" "redpanda" {
  count                   = local.create_nat
  name                    = "${var.resource_name_prefix}ngw-${var.region}"
  location                = var.region
  resource_group_name     = local.redpanda_network_resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = [element(local.natg_zone_ids, 0)]

  tags = var.tags

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_public_ip_prefix" "redpanda" {
  count               = local.create_nat
  name                = "${var.resource_name_prefix}ippre-${var.region}"
  location            = var.region
  resource_group_name = local.redpanda_network_resource_group_name
  prefix_length       = 31 # 2 IPs should offer more than enough source ports: 128k
  zones               = [element(local.natg_zone_ids, 0)]
  sku                 = "Standard"

  tags = var.tags

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "redpanda" {
  count               = local.create_nat
  nat_gateway_id      = azurerm_nat_gateway.redpanda[0].id
  public_ip_prefix_id = azurerm_public_ip_prefix.redpanda[0].id
}

resource "azurerm_subnet_nat_gateway_association" "redpanda" {
  for_each = var.create_nat ? var.private_subnets : {}

  subnet_id      = azurerm_subnet.private[each.key].id
  nat_gateway_id = azurerm_nat_gateway.redpanda[0].id
}
