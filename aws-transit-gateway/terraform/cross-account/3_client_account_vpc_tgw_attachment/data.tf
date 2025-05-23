## Client VPC and subnets
data "aws_subnet" "client" {
  id = var.client_subnet_id
}

data "aws_vpc" "client" {
  id = local.client_vpc_id
}

data "aws_subnets" "client" {
  filter {
    name   = "vpc-id"
    values = [local.client_vpc_id]
  }
}

data "aws_subnet" "client_subnet" {
  for_each = toset(data.aws_subnets.client.ids)
  id       = each.value
}

