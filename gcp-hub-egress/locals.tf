data "google_compute_zones" "available" {
  project = var.project
  region  = var.region
}

locals {
  zone = var.zone != "" ? var.zone : data.google_compute_zones.available.names[0]

  # Resolve each entry's project, defaulting to var.project when not set.
  redpanda_vpcs = {
    for k, v in var.redpanda_vpcs : k => {
      vpc_name  = v.vpc_name
      project   = v.project != "" ? v.project : var.project
      self_link = "projects/${v.project != "" ? v.project : var.project}/global/networks/${v.vpc_name}"
    }
  }
}
