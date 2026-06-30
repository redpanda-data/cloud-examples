# Hub → Redpanda spoke peering (hub side).
# allow_gateway_transit = true lets spokes use any VPN/ExpressRoute gateway
# attached to the hub VNet. Set use_remote_gateways = true on the spoke side
# (in customer-managed terraform) only if the hub has an actual gateway.
#
# The Redpanda platform creates the reciprocal spoke → hub peering during
# BYOC cluster provisioning, with allow_forwarded_traffic = true.
resource "azurerm_virtual_network_peering" "hub_to_redpanda" {
  for_each = var.redpanda_vnets

  name                         = "${var.common_prefix}-to-${each.key}"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = each.value.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}
