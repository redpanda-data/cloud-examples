output "transit_gateway_id" {
  description = "The Transit Gateway ID"
  value       = local.transit_gateway_id
}

output "transit_gateway_route_table_rp_id" {
  description = "The ID of Transit Gateway Route Table For Redpanda Cluster"
  value       = aws_ec2_transit_gateway_route_table.rp.id
}
