data "aws_security_group" "default" {
  vpc_id = local.client_vpc_id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] # Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "ena-support"
    values = [true]
  }
}

## Client VPC
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

# Redpanda K8s Cluster
data "aws_eks_cluster" "rp" {
  name = "redpanda-${var.rp_id}"
}

# Redpanda VPC
data "aws_vpc" "rp_vpc" {
  id = data.aws_eks_cluster.rp.vpc_config[0].vpc_id
}

data "aws_subnets" "rp_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.rp_vpc.id]
  }
  filter {
    name   = "tag:redpanda.subnet.private"
    values = ["1"]
  }
}

data "aws_subnet" "rp_subnet" {
  for_each = toset(data.aws_subnets.rp_subnets.ids)
  id       = each.value
}
