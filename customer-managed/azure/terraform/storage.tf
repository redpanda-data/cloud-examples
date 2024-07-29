locals {
  resource_name_prefix = replace(var.resource_name_prefix, "-", "")
}

resource "azurerm_storage_account" "management" {
  name                     = "${local.resource_name_prefix}${var.redpanda_management_storage_account_name}"
  resource_group_name      = azurerm_resource_group.redpanda.name
  location                 = azurerm_resource_group.redpanda.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  is_hns_enabled           = true
  access_tier              = "Hot"

  public_network_access_enabled   = true
  allow_nested_items_to_be_public = true

  cross_tenant_replication_enabled = false
  shared_access_key_enabled        = false

  blob_properties {
    versioning_enabled = false # not supported in StorageV2 with HNS
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.redpanda_agent.id]
  }

  tags = var.tags
}

resource "azurerm_storage_container" "management" {
  ###### TODO change var. to local.
  name                  = "${local.resource_name_prefix}${var.redpanda_management_storage_container_name}"
  storage_account_name  = azurerm_storage_account.management.name
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.management
  ]
}

resource "azurerm_storage_account" "tiered_storage" {
  name                     = "${local.resource_name_prefix}${var.redpanda_tiered_storage_account_name}"
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  is_hns_enabled           = true
  access_tier              = "Hot"

  # WARNING/FIXME: Disabling public access breaks Terraform
  # and the Azure Portal.
  public_network_access_enabled     = true
  allow_nested_items_to_be_public   = true
  cross_tenant_replication_enabled  = false
  shared_access_key_enabled         = false
  infrastructure_encryption_enabled = true
  enable_https_traffic_only         = true
  default_to_oauth_authentication   = true

  blob_properties {
    versioning_enabled = false
  }

  tags = var.tags
}

resource "azurerm_storage_container" "tiered_storage" {
  name                  = "${local.resource_name_prefix}${var.redpanda_tiered_storage_container_name}"
  storage_account_name  = azurerm_storage_account.tiered_storage.name
  container_access_type = "private"
}
