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


  config_rp_network                 = var.transit_gateway_route_table_rp_id == "" ? 1 : 0
  transit_gateway_route_table_rp_id = var.transit_gateway_route_table_rp_id == "" ? aws_ec2_transit_gateway_route_table.rp[0].id : var.transit_gateway_route_table_rp_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "rp" {
  count                                           = local.config_rp_network
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

resource "aws_ram_resource_share" "test_share" {
  name = "${local.resource_prefix}tgw-share"

  allow_external_principals = true # Allow sharing with external AWS accounts
}

# Share the transit gateway via RAM share.
resource "aws_ram_resource_association" "tgw" {
  resource_arn       = var.transit_gateway_id == "" ? aws_ec2_transit_gateway.test[0].arn : data.aws_ec2_transit_gateway.tgw[0].arn
  resource_share_arn = aws_ram_resource_share.test_share.arn
}

resource "aws_ram_principal_association" "tgw_invite" {
  for_each           = toset(var.transit_gateway_accepted_accounts)
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.test_share.arn
}

# Share resources without using invitations.
# OperationNotPermittedException: Unable to enable sharing with AWS Organizations.
# Received AccessDeniedException from AWSOrganizations with the following error message:
# You don't have permissions to access this resource
# resource "aws_ram_sharing_with_organization" "tgw" {}

resource "aws_ec2_transit_gateway_route_table" "rp" {
  count              = local.config_rp_network
  transit_gateway_id = local.transit_gateway_id
}

resource "aws_ec2_transit_gateway_route_table_association" "rp" {
  count                          = local.config_rp_network
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.rp[0].id
  transit_gateway_route_table_id = local.transit_gateway_route_table_rp_id
}

# No need to create a static route for the TGW attachment since we enable propagation.
# The TGW attachment will automatically propagate the routes to the TGW route table.
# It does not hurt to create a static route for the TGW attachment.
resource "aws_ec2_transit_gateway_route" "rp" {
  count                          = local.config_rp_network
  destination_cidr_block         = data.aws_vpc.rp_vpc.cidr_block
  transit_gateway_route_table_id = local.transit_gateway_route_table_rp_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.rp[0].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "rp" {
  count                          = local.config_rp_network
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.rp[0].id
  transit_gateway_route_table_id = local.transit_gateway_route_table_rp_id
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
  destination_cidr_block = var.client_vpc_cidr
  transit_gateway_id     = local.transit_gateway_id
}
