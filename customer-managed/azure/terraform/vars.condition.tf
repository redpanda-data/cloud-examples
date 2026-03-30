variable "create_role_assignment" {
  type        = bool
  default     = true
  description = <<-HELP
    Whether to create role assigments.
  HELP
}

variable "grant_caller_management_storage_access" {
  type        = bool
  default     = false
  description = <<-HELP
    If true, grants the caller (the identity running Terraform) the Storage Blob Data
    Contributor role on the management storage account. Required when running Terraform
    as a user or service principal, since the storage account has shared access keys
    disabled and only allows Azure AD authentication.
  HELP
}

variable "create_nat" {
  type        = bool
  default     = true
  description = <<-HELP
  Whether to create NAT gateway and its assoications
  HELP
}

