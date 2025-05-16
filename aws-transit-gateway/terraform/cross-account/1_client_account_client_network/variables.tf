variable "resource_prefix" {
  type        = string
  default     = ""
  description = <<-HELP
  The name prefix of resource to be created.
  HELP
}

variable "profile" {
  type        = string
  default     = "sandbox-cloud"
  description = <<-HELP
  AWS profile.
  HELP
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = <<-HELP
  AWS region.
  HELP
}

variable "client_subnet_id" {
  type        = string
  default     = ""
  description = <<-HELP
  The ID of a subnet where a test client/instance accessing RP services via Transit Gateway is deployed.
  If not provided, a new VPC and a subnet will be created.
  HELP
}

