locals {
  create_nat = var.create_nat ? 1 : 0
  // zone ids used for resources bound to the NAT gateways
  natg_zone_ids = [
    for m in data.azurerm_location.redpanda.zone_mappings :
    m.logical_zone if contains(slice(var.zones, 0, 1), m.physical_zone)
  ]

  use_gateway_egress   = var.hub_firewall_ip != "" || var.create_hub_firewall
  create_hub_vnet      = local.use_gateway_egress && var.hub_vnet_id == ""
  resolved_hub_vnet_id = var.hub_vnet_id != "" ? var.hub_vnet_id : (local.create_hub_vnet ? azurerm_virtual_network.hub[0].id : "")
  // When create_hub_firewall = true, derive the IP from the created resource.
  // Falls back to hub_firewall_ip for bring-your-own-firewall.
  resolved_firewall_ip = try(azurerm_firewall.hub[0].ip_configuration[0].private_ip_address, var.hub_firewall_ip)
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

# ---------------------------------------------------------------------------
# Gateway-transit egress (hub-and-spoke, no NAT gateway)
# Enabled by setting create_hub_firewall = true (fully managed) or by setting
# hub_firewall_ip to point at an existing firewall/NVA.
# Hub VNet and its firewall subnet are created when hub_vnet_id is not provided.
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network" "hub" {
  count               = local.create_hub_vnet ? 1 : 0
  name                = "${var.resource_name_prefix}hub-vnet"
  location            = var.region
  resource_group_name = local.redpanda_network_resource_group_name
  address_space       = var.hub_vnet_address_space

  tags = var.tags

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_subnet" "hub_firewall" {
  count = local.create_hub_vnet ? 1 : 0
  # Azure requires exactly this name for the Azure Firewall subnet.
  name                 = "AzureFirewallSubnet"
  resource_group_name  = local.redpanda_network_resource_group_name
  virtual_network_name = azurerm_virtual_network.hub[0].name
  address_prefixes     = [var.hub_firewall_subnet_cidr]
}

# -- Azure Firewall (only when create_hub_firewall = true) ------------------

resource "azurerm_public_ip" "hub_firewall" {
  count               = local.create_hub_vnet && var.create_hub_firewall ? 1 : 0
  name                = "${var.resource_name_prefix}hub-fw-pip"
  location            = var.region
  resource_group_name = local.redpanda_network_resource_group_name
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = var.tags

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_firewall_policy" "hub" {
  count               = local.create_hub_vnet && var.create_hub_firewall ? 1 : 0
  name                = "${var.resource_name_prefix}hub-fw-policy"
  location            = var.region
  resource_group_name = local.redpanda_network_resource_group_name
  sku                 = "Standard"

  tags = var.tags

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_firewall_policy_rule_collection_group" "hub" {
  count              = local.create_hub_vnet && var.create_hub_firewall ? 1 : 0
  name               = "DefaultRules"
  firewall_policy_id = azurerm_firewall_policy.hub[0].id
  priority           = 100

  # PoC rule: allow all outbound. Tighten this before production use.
  network_rule_collection {
    name     = "AllowEgressPoc"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "AllowAll"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}

resource "azurerm_firewall" "hub" {
  count               = local.create_hub_vnet && var.create_hub_firewall ? 1 : 0
  name                = "${var.resource_name_prefix}hub-fw"
  location            = var.region
  resource_group_name = local.redpanda_network_resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.hub[0].id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_firewall[0].id
    public_ip_address_id = azurerm_public_ip.hub_firewall[0].id
  }

  tags = var.tags
}

# -- Peerings (both directions when we own the hub VNet) --------------------

resource "azurerm_virtual_network_peering" "to_hub" {
  count = local.use_gateway_egress && var.create_vnet_peering ? 1 : 0

  name                         = "${var.resource_name_prefix}peering-to-hub"
  resource_group_name          = local.redpanda_network_resource_group_name
  virtual_network_name         = local.vnet_name
  remote_virtual_network_id    = local.resolved_hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  # Enables BGP route propagation through the hub's VPN/ExpressRoute gateway.
  # Requires hub to have a gateway with allow_gateway_transit = true.
  use_remote_gateways = var.use_remote_gateway

  # Subnet associations mutate the VNet and leave it in Updating state.
  # Wait for them to complete before attempting to peer.
  depends_on = [azurerm_subnet_route_table_association.private_gateway_egress]
}

resource "azurerm_virtual_network_peering" "from_hub" {
  count = local.create_hub_vnet && var.create_vnet_peering ? 1 : 0

  name                         = "${var.resource_name_prefix}peering-to-redpanda"
  resource_group_name          = local.redpanda_network_resource_group_name
  virtual_network_name         = azurerm_virtual_network.hub[0].name
  remote_virtual_network_id    = local.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true

  depends_on = [azurerm_subnet_route_table_association.private_gateway_egress]
}

# -- UDR: route all private subnet egress through the hub firewall ----------

resource "azurerm_route_table" "gateway_egress" {
  count               = local.use_gateway_egress ? 1 : 0
  name                = "${var.resource_name_prefix}rt-gateway-egress"
  location            = var.region
  resource_group_name = local.redpanda_network_resource_group_name

  tags = var.tags

  depends_on = [azurerm_resource_group.all]
}

resource "azurerm_route" "default_via_hub_firewall" {
  count                  = local.use_gateway_egress ? 1 : 0
  name                   = "default-via-hub-firewall"
  resource_group_name    = local.redpanda_network_resource_group_name
  route_table_name       = azurerm_route_table.gateway_egress[0].name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = local.resolved_firewall_ip
}

resource "azurerm_subnet_route_table_association" "private_gateway_egress" {
  for_each = local.use_gateway_egress ? var.private_subnets : {}

  subnet_id      = azurerm_subnet.private[each.key].id
  route_table_id = azurerm_route_table.gateway_egress[0].id
}
