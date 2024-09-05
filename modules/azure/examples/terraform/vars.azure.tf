###########################################################################
# Account/subscription identities
###########################################################################
variable "azure_client_id" {
  type        = string
  default     = ""
  description = <<-HELP
    The client ID of the application used to authenticate with Azure
  HELP
}

variable "azure_client_secret" {
  type        = string
  default     = ""
  description = <<-HELP
    The client secret of the application used to authenticate with Azure
  HELP
}

variable "azure_tenant_id" {
  type        = string
  default     = "9a95fd9e-005d-487a-9a01-d08c1eab2757"
  description = <<-HELP
    The subscription ID where the Redpanda cluster will live
  HELP
}

variable "azure_subscription_id" {
  type        = string
  default     = "60fc0bed-3072-4c53-906a-d130a934d520"
  description = <<-HELP
    The subscription ID where the Redpanda cluster will live
  HELP
}

variable "azure_use_msi" {
  type        = bool
  default     = false
  description = <<-HELP
    Whether to use Azure Managed Identity authentication (formerly MSI)
  HELP
}

variable "azure_use_cli" {
  type        = bool
  default     = true
  description = <<-HELP
    Whether to use the Azure CLI or Azure API directly
  HELP
}

variable "azure_use_oidc" {
  type        = bool
  default     = false
  description = <<-HELP
    Whether to use Azure OIDC authentication
  HELP
}
