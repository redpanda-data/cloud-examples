terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.98.0"
    }
  }

}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_prefix}_vnet"
  address_space       = [var.vnet_cidr]
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.resource_prefix}_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vnet_subnet] # Adjust the subnet CIDR block as needed
}

resource "azurerm_private_endpoint" "service-endpoint" {
  name                = "${var.resource_prefix}_service_endpoint"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet.id


  private_service_connection {
    name                           = "${var.resource_prefix}_service_connection"
    private_connection_resource_id = var.rp_endpoint_service_id
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "example-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.example.id]
  }
}

resource "azurerm_private_dns_zone" "example" {
  name                = var.rp_domain
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_a_record" "example" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.example.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.service-endpoint.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "${var.resource_prefix}_example_link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}


