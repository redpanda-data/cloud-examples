data "azurerm_client_config" "current" {}

data "azurerm_location" "redpanda" {
  location = var.region
}
