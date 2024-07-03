resource "aws_eip" "nat_gateway" {
  domain = "vpc"
}

resource "aws_internet_gateway" "redpanda" {
  vpc_id = aws_vpc.redpanda.id
}

resource "aws_nat_gateway" "redpanda" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public[0].id
  depends_on = [
    aws_internet_gateway.redpanda,
  ]
}

resource "aws_route" "nat" {
  count                  = length(var.private_subnet_cidrs)
  route_table_id         = aws_route_table.private.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.redpanda.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.redpanda.id
}
