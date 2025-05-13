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

variable "transit_gateway_id" {
  type        = string
  default     = ""
  description = <<-HELP
  The ID of the Transit Gateway to be used.
  If not provided, a new Transit Gateway will be created.
  HELP
}

variable "client_vpc_cidr" {
  type        = string
  default     = ""
  description = <<-HELP
  The CIDR block of the client VPC.
  HELP
}

variable "rp_id" {
  type        = string
  description = <<-HELP
  Redpanda cluster ID.
  HELP
}

variable "transit_gateway_accepted_accounts" {
  type        = list(string)
  description = <<-HELP
  List of AWS accounts to accept Transit Gateway attachments from.
  HELP
}

variable "transit_gateway_route_table_rp_id" {
  type        = string
  default     = ""
  description = <<-HELP
  The ID of the Transit Gateway route table to be used for RP VPC.
  HELP
}
