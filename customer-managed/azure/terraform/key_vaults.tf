locals {
  allowed_subnet_ids = [for s in azurerm_subnet.private : s.id]
}


resource "azurerm_key_vault" "vault" {
  count               = var.redpanda_management_key_vault_name != "" ? 1 : 0
  name                = "${var.resource_name_prefix}${var.redpanda_management_key_vault_name}"
  resource_group_name = azurerm_resource_group.redpanda.name
  location            = azurerm_resource_group.redpanda.location
  sku_name            = "standard"
  tenant_id           = var.azure_tenant_id

  public_network_access_enabled = true

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = true
  enable_rbac_authorization       = true

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Allow"
    virtual_network_subnet_ids = local.allowed_subnet_ids
  }

  access_policy {
    tenant_id      = var.azure_tenant_id
    object_id      = data.azurerm_client_config.current.object_id
    application_id = data.azurerm_client_config.current.client_id

    secret_permissions = [
      "Set",
      "Get",
      "List",
      "Delete",
      "Purge",
      "Recover",
      "Restore",
      "Backup",
    ]
  }

  tags = var.tags
}

resource "azurerm_key_vault" "console" {
  count               = var.redpanda_console_key_vault_name != "" ? 1 : 0
  name                = "${var.resource_name_prefix}${var.redpanda_console_key_vault_name}"
  resource_group_name = azurerm_resource_group.redpanda.name
  location            = azurerm_resource_group.redpanda.location
  sku_name            = "standard"
  tenant_id           = var.azure_tenant_id

  public_network_access_enabled = true

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = true
  enable_rbac_authorization       = true

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Allow"
    virtual_network_subnet_ids = local.allowed_subnet_ids
  }

  access_policy {
    tenant_id      = var.azure_tenant_id
    object_id      = data.azurerm_client_config.current.object_id
    application_id = data.azurerm_client_config.current.client_id

    secret_permissions = [
      "Set",
      "Get",
      "List",
      "Delete",
      "Purge",
      "Recover",
      "Restore",
      "Backup",
    ]
  }

  tags = var.tags
}
