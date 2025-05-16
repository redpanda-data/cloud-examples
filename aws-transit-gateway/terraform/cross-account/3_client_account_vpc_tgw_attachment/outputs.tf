output "vpc_transit_gateway_attachment_id" {
  description = "VPC Transit Gateway Attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.rp.id
}
