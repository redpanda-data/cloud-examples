resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "rp" {
  count                         = var.accept_attachment ? 1 : 0
  transit_gateway_attachment_id = var.vpc_attachment_id
}

resource "aws_ec2_transit_gateway_route_table_association" "client" {
  transit_gateway_attachment_id  = var.vpc_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_rp_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.rp]
}

# No need to create a static route for the TGW attachment since we enable propagation.
# The TGW attachment will automatically propagate the routes to the TGW route table.
# It does not hurt to create a static route for the TGW attachment.
resource "aws_ec2_transit_gateway_route" "client" {
  destination_cidr_block         = var.client_vpc_cidr
  transit_gateway_route_table_id = var.transit_gateway_route_table_rp_id
  transit_gateway_attachment_id  = var.vpc_attachment_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.rp]
}

resource "aws_ec2_transit_gateway_route_table_propagation" "client" {
  transit_gateway_attachment_id  = var.vpc_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_rp_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.rp]
}
