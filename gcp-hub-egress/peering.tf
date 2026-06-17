resource "google_compute_network_peering" "hub_to_redpanda" {
  for_each = local.redpanda_vpcs

  name         = "${var.common_prefix}-to-${each.key}"
  network      = google_compute_network.hub.self_link
  peer_network = each.value.self_link

  # Advertise the custom default internet route (0.0.0.0/0) into the Redpanda VPC
  # so that all internet-bound traffic from Redpanda nodes exits via this hub's NAT.
  export_custom_routes = true
  import_custom_routes = false

  export_subnet_routes_with_public_ip = false
  import_subnet_routes_with_public_ip = false
}
