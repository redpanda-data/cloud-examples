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

variable "rp_id" {
  type        = string
  description = <<-HELP
  Redpanda cluster ID.
  HELP
}

variable "vpc_attachment_id" {
  type        = string
  description = <<-HELP
  The ID of the VPC attachment to be accepted.
  HELP
}

variable "transit_gateway_id" {
  type        = string
  description = <<-HELP
  The ID of the Transit Gateway to be used.
  HELP
}

variable "transit_gateway_route_table_rp_id" {
  type        = string
  description = <<-HELP
  The ID of the Transit Gateway Route Table to be used for Redpanda Cluster.
  HELP
}

variable "client_vpc_cidr" {
  type        = string
  description = <<-HELP
  The CIDR block of the client VPC.
  HELP
}
