
locals {
  resource_prefix = (var.resource_prefix) == "" ? "" : replace(var.resource_prefix, "_", "-")

  client_vpc_cidr_block    = "10.20.0.0/16"
  client_subnet_cidr_block = "10.20.1.0/24"
  client_subnet_id         = var.client_subnet_id == "" ? aws_subnet.client[0].id : var.client_subnet_id
  client_vpc_id            = var.client_subnet_id == "" ? aws_vpc.client[0].id : data.aws_subnet.client.vpc_id
}

resource "aws_vpc" "client" {
  count                = var.client_subnet_id == "" ? 1 : 0
  cidr_block           = local.client_vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "client" {
  count      = var.client_subnet_id == "" ? 1 : 0
  vpc_id     = aws_vpc.client[0].id
  cidr_block = local.client_subnet_cidr_block
}
