output "hub_vpc_name" {
  value       = google_compute_network.hub.name
  description = "Hub VPC network name. Pass this to Redpanda when creating the cluster."
}

output "hub_vpc_self_link" {
  value       = google_compute_network.hub.self_link
  description = "Full self-link URL of the hub VPC."
}

output "hub_project_id" {
  value       = var.project
  description = "GCP project ID of the hub VPC. Required by Redpanda for cross-project peering."
}

output "hub_subnet_name" {
  value       = google_compute_subnetwork.hub.name
  description = "Name of the hub subnet."
}

output "nat_public_ip" {
  value       = google_compute_address.nat.address
  description = "Public IP address all Redpanda egress traffic will appear from."
}
