variable "project" {
  type        = string
  description = "GCP project ID where the hub VPC and Cloud NAT will be created."
}

variable "region" {
  type        = string
  description = "GCP region for all resources."
}

variable "zone" {
  type        = string
  default     = ""
  description = "GCP zone for the NAT gateway VM. Defaults to the first available zone in var.region."
}

variable "nat_machine_type" {
  type        = string
  default     = "e2-micro"
  description = "Machine type for the NAT gateway VM. Larger types get higher egress bandwidth caps; size up if the NAT becomes a throughput bottleneck."
}

variable "nat_image" {
  type        = string
  default     = "debian-cloud/debian-13"
  description = "Boot image for the NAT gateway VM."
}

variable "nat_disk_size_gb" {
  type        = number
  default     = 10
  description = "Boot disk size (GB) for the NAT gateway VM."
}

variable "nat_source_ranges" {
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "100.64.0.0/10"]
  description = "Source CIDRs allowed to reach the NAT gateway for forwarding. Defaults to all RFC-1918 + CGNAT; narrow this to your Redpanda spoke VPC CIDR(s) for tighter ingress control."
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels applied to all resources that support labeling (e.g. team, cost-center, environment)."
}

variable "routing_mode" {
  type        = string
  default     = "REGIONAL"
  description = "VPC routing mode"
}

variable "common_prefix" {
  type        = string
  default     = "hub"
  description = "Prefix applied to all resource names."
}

variable "hub_subnet_cidr" {
  type        = string
  default     = "100.64.0.0/20"
  description = <<-HELP
  CIDR for the hub/egress subnet.
  Must not overlap with the Redpanda cluster VPC CIDR — VPC peering is rejected
  when CIDRs overlap and routing will break silently if they collide after the fact.
  100.64.0.0/20 (CGNAT range) is a safe default: it is not routable on the public
  internet and is unlikely to conflict with spoke VPC CIDRs.
  HELP
}

variable "redpanda_vpcs" {
  type = map(object({
    vpc_name = string
    project  = optional(string, "")
  }))
  default = {
  }
  description = <<-HELP
  Map of Redpanda BYOC cluster VPCs to peer with the hub. The map key is used as
  the peering name suffix (e.g. "cluster-1" → "$${common_prefix}-to-cluster-1").

  The VPC name follows the pattern "redpanda-<network_id>" and is known before
  cluster creation — it can be derived from the network ID visible in the Redpanda
  Cloud console before running "rpk byoc apply". This means entries can be added
  here on the first terraform apply, alongside the hub infrastructure.

  project defaults to var.project when omitted or empty.

  Example:
    redpanda_vpcs = {
      "cluster-a" = { vpc_name = "redpanda-abc123", project = "my-gcp-project" }
      "cluster-b" = { vpc_name = "redpanda-def456" }
    }
  HELP
}
