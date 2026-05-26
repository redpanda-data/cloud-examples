resource "google_compute_address" "nat" {
  project = var.project
  region  = var.region
  name    = "${var.common_prefix}-nat-ip"
}

# Reserved internal IP so the spoke-to-nat route (next_hop_ip) stays valid
# across MIG instance replacements.
resource "google_compute_address" "nat_internal" {
  project      = var.project
  region       = var.region
  name         = "${var.common_prefix}-nat-internal-ip"
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.hub.self_link
}

resource "google_compute_instance_template" "nat" {
  project        = var.project
  region         = var.region
  name_prefix    = "${var.common_prefix}-nat-"
  machine_type   = var.nat_machine_type
  can_ip_forward = true
  tags           = ["nat-direct"]

  disk {
    source_image = var.nat_image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.nat_disk_size_gb
    disk_type    = "pd-balanced"
  }

  network_interface {
    network    = google_compute_network.hub.self_link
    subnetwork = google_compute_subnetwork.hub.self_link
    network_ip = google_compute_address.nat_internal.address
    access_config {
      nat_ip = google_compute_address.nat.address
    }
  }

  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    set -e
    sysctl -w net.ipv4.ip_forward=1
    echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.d/99-ip-forward.conf
    EXT_IF=$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -1)
    iptables -t nat -A POSTROUTING -o "$EXT_IF" -j MASQUERADE
    iptables -A FORWARD -i "$EXT_IF" -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -j ACCEPT
    apt-get update -qq && apt-get install -y -qq iptables-persistent
    netfilter-persistent save
  SCRIPT

  lifecycle {
    create_before_destroy = true
  }
}

# MIG of size 1: auto-restarts the NAT VM if the instance crashes or is terminated.
resource "google_compute_instance_group_manager" "nat" {
  project            = var.project
  zone               = local.zone
  name               = "${var.common_prefix}-nat-mig"
  base_instance_name = "${var.common_prefix}-nat"
  target_size        = 1

  version {
    instance_template = google_compute_instance_template.nat.self_link
  }
}

# Allow RFC-1918 + CGNAT traffic to reach the NAT VM for forwarding.
# GCP firewall evaluates ingress rules against the destination VM for IP-forwarded packets.
resource "google_compute_firewall" "nat_forwarding" {
  project = var.project
  name    = "${var.common_prefix}-allow-nat-forward"
  network = google_compute_network.hub.name

  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }

  source_ranges = var.nat_source_ranges
  target_tags   = ["nat-direct"]
}
