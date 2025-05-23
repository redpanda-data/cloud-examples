output "ssh_private_key" {
  description = "SSH key to EC instance"
  value       = tls_private_key.test.private_key_pem
  sensitive   = true
}

output "instance_public_ip" {
  description = "Instance public IP"
  value       = var.deploy_test_client ? aws_eip.test_instance_eip[0].public_ip : null
}

output "instance_id" {
  description = "Instance ID"
  value       = var.deploy_test_client ? aws_eip.test_instance_eip[0].id : null
}

output "transit_gateway_route_table_rp_id" {
  description = "Transit Gateway Route Table ID for Redpanda"
  value       = local.transit_gateway_route_table_rp_id
}

locals {
  cert_file = var.deploy_test_client ? format("/tmp/%s.pem", aws_eip.test_instance_eip[0].public_ip) : null
}
output "ssh_to_ec2_commands" {
  description = "SSH to EC2 instance commands"
  # Terraform go code has issue to unmarshall the output. So no output if running inside the certification tests.
  value = var.deploy_test_client ? {
    "get_ssh_key_command" : <<EOF
    cat terraform.tfstate | jq .outputs.ssh_private_key.value | sed 's/"//g' | awk '{gsub(/\\n/,"\n")}1' > ${local.cert_file}; chmod 600 ${local.cert_file}
    EOF
    "ssh_command" : format("ssh -i %s redpanda@%s", local.cert_file, aws_eip.test_instance_eip[0].public_ip)
    "test_redpanda_transit_gateway_command" : "/usr/local/bin/test-transit-gateway.sh <rp-user-id> <rp-user-password>"
  } : null
}
