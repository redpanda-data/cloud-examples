terraform {
  #backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.98.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = false

  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id

  use_cli  = var.azure_use_cli
  use_msi  = var.azure_use_msi
  use_oidc = var.azure_use_oidc

  # Always use Entra ID authentication instead of shared static keys
  # If set to false, we get
  # Error: retrieving queue properties for Storage Account (Subscription: "60fc0bed-3072-4c53-906a-d130a934d520"
  # Resource Group Name: "pz-tiered-storage-rg"
  # Storage Account Name: "pztieredstorage"): unmarshalling response: could not parse response body
  storage_use_azuread = true
}
