provider "aws" {
  # environment or the global credentials file.
  default_tags {
    tags = {
      access-redpanda-transit-gateway = true
      environment = "development"
      name = "redpanda_client_vpc_tgw"
    }
  }
  region = var.region
}

