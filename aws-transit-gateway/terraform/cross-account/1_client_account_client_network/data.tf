data "aws_subnet" "client" {
  id = local.client_subnet_id
}

data "aws_vpc" "client" {
  id = local.client_vpc_id
}

