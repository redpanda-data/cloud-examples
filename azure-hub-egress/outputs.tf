output "hub_vnet_id" {
  value       = azurerm_virtual_network.hub.id
  description = "Resource ID of the hub VNet. Required by Redpanda when configuring hub egress."
}

output "hub_vnet_name" {
  value       = azurerm_virtual_network.hub.name
  description = "Name of the hub VNet."
}

output "hub_resource_group_name" {
  value       = azurerm_resource_group.hub.name
  description = "Resource group containing the hub resources."
}

output "firewall_private_ip" {
  value       = azurerm_firewall.hub.ip_configuration[0].private_ip_address
  description = "Private IP of the Azure Firewall. Pass to Redpanda as hub_firewall_ip — Redpanda will create a UDR on spoke subnets routing 0.0.0.0/0 to this IP."
}

output "firewall_public_ip" {
  value       = azurerm_public_ip.firewall.ip_address
  description = "Public IP all Redpanda egress traffic will appear from."
}
