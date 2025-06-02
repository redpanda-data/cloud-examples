output "vpc_id" {
  description = "Client VPC ID"
  value       = local.client_vpc_id
}

output "subnet_id" {
  description = "Client subnet ID"
  value       = local.client_subnet_id
}

output "client_vpc_cidr" {
  description = "Client VPC CIDR block"
  value       = data.aws_vpc.client.cidr_block
}
