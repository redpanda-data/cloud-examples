resource "aws_vpc" "redpanda" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.redpanda.id
  availability_zone_id    = element(var.zones, count.index)
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.default_tags,
    {
      # Hints k8s where it can provision public network load balancers.
      "kubernetes.io/role/elb" = 1,
      # We add this tag to enable discovering the subnet from Terraform code
      # that provisions Redpanda clusters, as another alternative.
      "redpanda.subnet.public" = 1
    }
  )
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.redpanda.id
  availability_zone_id    = element(var.zones, count.index)
  cidr_block              = var.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.default_tags,
    {
      # Hints k8s where it can provision private network load balancers.
      "kubernetes.io/role/internal-elb" = 1,
      # We add this tag to enable discovering the subnet from Terraform code
      # that provisions Redpanda clusters, as another alternative.
      "redpanda.subnet.private" = 1
    }
  )
}

data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

# Creates a private gateway vpc endpoint for S3 traffic. So traffic to S3
# doesn't go through the NAT gateway, which is more expensive.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.redpanda.id
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type = data.aws_vpc_endpoint_service.s3.service_type
}

# This block has 2 purposes:
#
# 1. Ensures that the default security group created by the VPC is properly
#    tagged with the default provider tags.
# 2. Since the default security group is not used by any of the resources
#    managed by Redpanda, for security, we're denying all ingress and egress
#    traffic.
#
# ----------
# Important:
# ----------
# The `aws_default_security_group` resource behaves differently from normal
# resources. Terraform does not create this resource but instead attempts to
# "adopt" it into management. On adoption it immediately removes all ingress and
# egress rules in the security group and recreates it with the rules specified
# here. Check the docs for more details.
resource "aws_default_security_group" "redpanda" {
  vpc_id  = aws_vpc.redpanda.id
  ingress = []
  egress  = []
}
