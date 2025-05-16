locals {
  client_vpc_id = data.aws_subnet.client.vpc_id

  # The IDs of a subnet in each availability zone
  # TGW: select one subnet for each Availability Zone to be used by the transit gateway to route traffic.
  # You must select at least one subnet. You can select only one subnet per Availability Zone.
  az_client_subnet_ids = [
    for az, subnets in {
      for subnet_id, subnet in data.aws_subnet.client_subnet :
      subnet.availability_zone => subnet_id...
    } :
    subnets[0] # Select the first subnet in each availability zone
  ]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "rp" {
  subnet_ids                                      = local.az_client_subnet_ids
  transit_gateway_id                              = var.transit_gateway_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = true
  vpc_id                                          = local.client_vpc_id
}
