resource "google_compute_network" "hub" {
  project                         = var.project
  name                            = "${var.common_prefix}-vpc"
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "hub" {
  project       = var.project
  region        = var.region
  name          = "${var.common_prefix}-subnet"
  network       = google_compute_network.hub.id
  ip_cidr_range = var.hub_subnet_cidr
}

# Tagged route: only the NAT VM (tag "nat-direct") uses this to reach the internet.
# Priority 100 ensures this beats the untagged spoke-to-nat route below, preventing
# the NAT VM from routing its own egress back to itself.
resource "google_compute_route" "nat_to_internet" {
  project          = var.project
  name             = "${var.common_prefix}-nat-to-internet"
  network          = google_compute_network.hub.name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  tags             = ["nat-direct"]
  priority         = 100
}

# Untagged route: next_hop_instance routes ARE exportable via VPC peering (unlike
# next_hop_gateway = "default-internet-gateway" which GCP never exports).
# Priority 900 so the imported copy in the Redpanda spoke VPC wins against the
# spoke's own system default route (priority 1000).
#
# CRITICAL: GCP's routing rule is that LOCAL static routes always beat IMPORTED
# peering routes regardless of priority. The Redpanda spoke VPC MUST be created
# with delete_default_routes_on_create = true so it has no local 0.0.0.0/0 route.
# If a local default route exists, it will always win over this imported route
# and no traffic will flow through hub-nat. To remove an existing default route:
# gcloud compute routes delete <default-route-name> --network=<redpanda-vpc>
resource "google_compute_route" "spoke_to_nat" {
  project     = var.project
  name        = "${var.common_prefix}-spoke-to-nat"
  network     = google_compute_network.hub.name
  dest_range  = "0.0.0.0/0"
  next_hop_ip = google_compute_address.nat_internal.address
  priority    = 900
}
