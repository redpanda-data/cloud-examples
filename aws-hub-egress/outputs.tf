output "transit_gateway_id" {
  value       = aws_ec2_transit_gateway.hub.id
  description = "Pass this to the Redpanda BYOC module as transit_gateway_id."
}

output "transit_gateway_arn" {
  value       = aws_ec2_transit_gateway.hub.arn
  description = "ARN of the Transit Gateway."
}

output "ram_resource_share_arn" {
  value       = local.create_ram_share ? aws_ram_resource_share.tgw[0].arn : null
  description = "ARN of the RAM share. Redpanda must accept this invitation before attaching. Null when hub and spoke share the same account."
}

output "hub_vpc_id" {
  value       = aws_vpc.hub.id
  description = "ID of the hub/egress VPC."
}

output "nat_gateway_public_ip" {
  value       = aws_eip.nat.public_ip
  description = "Public IP of the NAT Gateway — all spoke egress traffic will appear from this IP."
}
