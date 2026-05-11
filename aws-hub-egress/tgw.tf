resource "aws_ec2_transit_gateway" "hub" {
  description                     = "Hub TGW for centralized egress"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = merge(var.default_tags, { Name = "${var.common_prefix}-tgw" })
}

# Default route in the TGW route table → hub VPC attachment.
# Spoke VPCs that attach will have internet-bound traffic forwarded here.
resource "aws_ec2_transit_gateway_route" "default_egress" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.hub.association_default_route_table_id
}

# Attach the hub VPC to the TGW using the private subnets.
resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  transit_gateway_id = aws_ec2_transit_gateway.hub.id
  vpc_id             = aws_vpc.hub.id
  subnet_ids         = aws_subnet.private[*].id

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = merge(var.default_tags, { Name = "${var.common_prefix}-tgw-attachment" })
}

resource "aws_ram_resource_share" "tgw" {
  count                     = local.create_ram_share ? 1 : 0
  name                      = "${var.common_prefix}-tgw-share"
  allow_external_principals = true
  tags                      = var.default_tags
}

resource "aws_ram_resource_association" "tgw" {
  count              = local.create_ram_share ? 1 : 0
  resource_arn       = aws_ec2_transit_gateway.hub.arn
  resource_share_arn = aws_ram_resource_share.tgw[0].arn
}

resource "aws_ram_principal_association" "redpanda" {
  count              = local.create_ram_share ? 1 : 0
  principal          = var.spoke_aws_account_id
  resource_share_arn = aws_ram_resource_share.tgw[0].arn
}
