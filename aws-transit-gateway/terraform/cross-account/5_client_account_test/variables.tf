variable "resource_prefix" {
  type        = string
  default     = ""
  description = <<-HELP
  The name prefix of resource to be created.
  HELP
}

variable "profile" {
  type        = string
  default     = "sandbox-cloud"
  description = <<-HELP
  AWS profile.
  HELP
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = <<-HELP
  AWS region.
  HELP
}

variable "transit_gateway_id" {
  type        = string
  default     = ""
  description = <<-HELP
  The ID of the Transit Gateway to be used.
  If not provided, a new Transit Gateway will be created.
  HELP
}

variable "client_subnet_id" {
  type        = string
  default     = ""
  description = <<-HELP
  The ID of a subnet where a test client/instance accessing RP services via Transit Gateway is deployed.
  If not provided, a new VPC and a subnet will be created.
  HELP
}

variable "rp_id" {
  type        = string
  description = <<-HELP
  Redpanda cluster ID.
  HELP
}

variable "rp_vpc_cidr" {
  type        = string
  description = <<-HELP
  The CIDR block of the Redpanda VPC.
  HELP
}

variable "rp_kafka_seed_url" {
  type        = string
  description = <<-HELP
  The domain of RP cluster, e.g. seed-1cb35323.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com:9092
  HELP
}

variable "rp_http_proxy_seed_url" {
  type        = string
  description = <<-HELP
  The domain of RP cluster, e.g. https://pandaproxy-c9b46fc1.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com:30082
  HELP
}

variable "rp_schema_registry_url" {
  type        = string
  description = <<-HELP
  The domain of RP cluster, e.g. https://schema-registry-56a88df9.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com:30081
  HELP
}

variable "rp_console_url" {
  type        = string
  description = <<-HELP
  The domain of RP cluster, e.g. https://console-1cb35323.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com
  HELP
}

