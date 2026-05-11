# Public subnet route table: internet exit via IGW + return routes to spokes via TGW.
# NAT Gateway reply traffic is forwarded back to spokes from here.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.hub.id
  tags   = merge(var.default_tags, { Name = "${var.common_prefix}-public-rt" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hub.id
}

# Return routes: one per spoke CIDR so NAT Gateway replies reach the correct spoke.
resource "aws_route" "public_to_spoke" {
  count                  = length(var.spoke_cidrs)
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = var.spoke_cidrs[count.index]
  transit_gateway_id     = aws_ec2_transit_gateway.hub.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.hub]
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private subnet route table: all traffic exits via NAT Gateway.
# TGW attachment lives in these subnets; ingress from spokes is routed to NAT here.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.hub.id
  tags   = merge(var.default_tags, { Name = "${var.common_prefix}-private-rt" })
}

resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.hub.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
