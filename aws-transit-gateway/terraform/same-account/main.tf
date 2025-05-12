locals {
  resource_prefix    = (var.resource_prefix) == "" ? "" : replace(var.resource_prefix, "_", "-")
  transit_gateway_id = var.transit_gateway_id == "" ? aws_ec2_transit_gateway.test[0].id : var.transit_gateway_id
}

resource "aws_ec2_transit_gateway" "test" {
  count                              = var.transit_gateway_id == "" ? 1 : 0
  description                        = "a transit gateway for routing traffic between client' VPCs and RP's VPC"
  auto_accept_shared_attachments     = "enable"
  default_route_table_association    = "disable"
  default_route_table_propagation    = "enable"
  dns_support                        = "enable"
  security_group_referencing_support = "enable"
}

resource "aws_ec2_transit_gateway_route_table" "rp" {
  transit_gateway_id = local.transit_gateway_id
}

locals {
  # The IDs of a subnet in each availability zone
  # TGW: select one subnet for each Availability Zone to be used by the transit gateway to route traffic.
  # You must select at least one subnet. You can select only one subnet per Availability Zone.
  az_rp_subnet_ids = [
    for az, subnets in {
      for subnet_id, subnet in data.aws_subnet.rp_subnet :
      subnet.availability_zone => subnet_id...
    } :
    subnets[0] # Select the first subnet in each availability zone
  ]

  az_client_subnet_ids = var.client_subnet_id == "" ? [aws_subnet.client[0].id] : [
    for az, subnets in {
      for subnet_id, subnet in data.aws_subnet.client_subnet :
      subnet.availability_zone => subnet_id...
    } :
    subnets[0] # Select the first subnet in each availability zone
  ]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "rp" {
  subnet_ids                                      = local.az_rp_subnet_ids
  transit_gateway_id                              = local.transit_gateway_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = true
  vpc_id                                          = data.aws_vpc.rp_vpc.id
  # This ensures that the transit gateway uses the same Availability Zone for that VPC attachment
  # for the lifetime of a flow of traffic between source and destination.
  # It also allows the transit gateway to send traffic to any Availability Zone in the VPC,
  # as long as there is a subnet association in that zone.
  appliance_mode_support = "enable"
}

resource "aws_ec2_transit_gateway_route_table_association" "rp" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.rp.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rp.id
}

resource "aws_ec2_transit_gateway_route" "rp" {
  destination_cidr_block         = data.aws_vpc.rp_vpc.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rp.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.rp.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "rp" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.rp.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rp.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "client" {
  subnet_ids                                      = local.az_client_subnet_ids
  transit_gateway_id                              = local.transit_gateway_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = true
  vpc_id                                          = local.client_vpc_id
}

resource "aws_ec2_transit_gateway_route_table_association" "client" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.client.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rp.id
}

resource "aws_ec2_transit_gateway_route" "client" {
  destination_cidr_block         = data.aws_vpc.client.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rp.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.client.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "client" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.client.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rp.id
}

resource "aws_security_group" "rp_tgw" {
  name        = "${local.resource_prefix}redpanda-tgw-sg"
  description = "TGW security group for traffic to/from clients"
  vpc_id      = data.aws_vpc.rp_vpc.id
}

resource "aws_security_group_rule" "rp_allow_to_client" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = [data.aws_vpc.client.cidr_block]
  protocol          = "tcp"
  security_group_id = aws_security_group.rp_tgw.id
}

# Routing table from RP VPC to TGW for traffic to clients
data "aws_route_tables" "rp_route_tables" {
  vpc_id = data.aws_vpc.rp_vpc.id

  filter {
    name   = "tag:Name"
    values = [data.aws_vpc.rp_vpc.tags["Name"]]
  }
}

resource "aws_route" "rp_to_tgw" {
  for_each = toset(data.aws_route_tables.rp_route_tables.ids)

  route_table_id         = each.value
  destination_cidr_block = data.aws_vpc.client.cidr_block
  transit_gateway_id     = local.transit_gateway_id
}
