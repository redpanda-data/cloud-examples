resource "azurerm_public_ip" "firewall" {
  name                = "${var.common_prefix}-fw-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_firewall_policy" "hub" {
  name                = "${var.common_prefix}-fw-policy"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "hub" {
  name               = "DefaultRules"
  firewall_policy_id = azurerm_firewall_policy.hub.id
  priority           = 100

  # Allow all outbound egress. Restrict to specific destinations before production use.
  network_rule_collection {
    name     = "AllowEgress"
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

# Azure Firewall (Standard tier, ~$1.25/hr). Destroy when not in use.
resource "azurerm_firewall" "hub" {
  name                = "${var.common_prefix}-fw"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.hub.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  tags = var.tags
}
