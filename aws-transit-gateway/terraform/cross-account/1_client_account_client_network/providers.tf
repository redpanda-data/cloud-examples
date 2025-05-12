provider "aws" {
  # environment or the global credentials file.
  default_tags {
    tags = {
      access-redpanda-transit-gateway = true
    }
  }
  region = var.region
}

