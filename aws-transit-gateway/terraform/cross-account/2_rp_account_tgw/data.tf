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

data "aws_ec2_transit_gateway" "tgw" {
  count = var.transit_gateway_id == "" ? 0 : 1
  id    = var.transit_gateway_id
}
