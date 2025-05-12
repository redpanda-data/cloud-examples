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

variable "client_subnet_id" {
  type        = string
  default     = ""
  description = <<-HELP
  The ID of a subnet where a test client/instance accessing RP services via Transit Gateway is deployed.
  If not provided, a new VPC and a subnet will be created.
  HELP
}

variable "rp_id" {
  type        = string
  description = <<-HELP
  Redpanda cluster ID.
  HELP
}

