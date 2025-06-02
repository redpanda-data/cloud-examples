provider "aws" {
  # environment or the global credentials file.
  default_tags {
    tags = {
      rp-id = var.rp_id
    }
  }
  region = var.region
}

