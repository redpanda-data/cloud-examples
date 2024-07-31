locals {
  kafka_api_seed_nlb_listener_port       = 30292
  schema_registry_seed_nlb_listener_port = 30081
  rp_proxy_seed_nlb_listener_port        = 30282

  kafka_api_node_nlb_listener_port = 32092
  rp_proxy_node_nlb_listener_port  = 31082

  console_port = 443

  resource_prefix = (var.resource_prefix) == "" ? "" : replace(var.resource_prefix, "_", "-")


  cert_file = format("/tmp/%s.pem", azurerm_public_ip.public_ip.ip_address)

}


output "instance_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "rp_kafka_api_node_endpoints" {
  description = "Redpanda Kafka service urls"
  value = var.resource_prefix == "" ? {
    for i in range(var.rp_node_count) : format("kafka_api_node%d_endpoint", i) => format("%s:%d", var.rp_domain, local.kafka_api_node_nlb_listener_port + i)
  } : null
}

output "rp_rp_proxy_node_endpoints" {
  description = "Redpanda proxy service urls"
  value = var.resource_prefix == "" ? {
    for i in range(var.rp_node_count) : format("redpanda_proxy_node%d_endpoint", i) => format("%s:%d", var.rp_domain, local.rp_proxy_node_nlb_listener_port + i)
  } : null
}

output "rp_seed_endpoints" {
  description = "Redpanda service seed urls"
  value = var.resource_prefix == "" ? {
    "kafka_api_seed" : format("%s:%d", var.rp_domain, local.kafka_api_seed_nlb_listener_port)
    "schema_registry_seed" : format("%s:%d", var.rp_domain, local.schema_registry_seed_nlb_listener_port)
    "redpanda_proxy_seed" : format("%s:%d", var.rp_domain, local.rp_proxy_seed_nlb_listener_port)
  } : null
}

output "ssh_private_key" {
  description = "SSH key to EC instance"
  value       = tls_private_key.key.private_key_pem
  sensitive   = true
}

output "private_key_file_path" {
  value = abspath(local_file.private_key.filename)
}

output "ssh_to_ec2_commands" {
  description = "SSH to EC2 instance commands"
  # Terraform go code has issue to unmarshall the output. So no output if running inside the certification tests.
  value = var.resource_prefix == "" ? {
    "get_ssh_key_command" : <<EOF
    cat terraform.tfstate | jq .outputs.ssh_private_key.value | sed 's/"//g' | awk '{gsub(/\\n/,"\n")}1' > ${local.cert_file}; chmod 600 ${local.cert_file}
    EOF
    "ssh_command" : format("ssh -i %s redpanda@%s", local.cert_file, azurerm_public_ip.public_ip.ip_address)
  } : null
}