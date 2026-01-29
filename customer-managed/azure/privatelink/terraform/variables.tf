
variable "vnet_cidr" {
  default     = "10.0.0.0/16"
  description = <<-HELP
  The CIDR of the vnet.
  HELP
}

variable "vnet_subnet" {
  default     = "10.0.0.0/24"
  description = <<-HELP
  The CIDR of the subnet.
  HELP
}

variable "resource_group_name" {
  description = <<-HELP
  The resource group name for all the resources to be created under.
  HELP
}

variable "rp_endpoint_service_id" {
  description = <<-HELP
  The id of the endpoint service.
  HELP
}

variable "rp_id" {
  description = <<-HELP
  The id of the redpanda instance.
  HELP
}

variable "rp_domain" {
  type        = string
  description = <<-HELP
  The domain of RP cluster, e.g. cki01qgth38kk81ard3g.fmc.dev.cloud.redpanda.com.
  HELP
}

variable "rp_node_count" {
  type        = number
  description = <<-HELP
  The number of Redpanda nodes.
  HELP
}

variable "resource_prefix" {
  type        = string
  default     = "rp"
  description = <<-HELP
  The name prefix of resource to be created.
  HELP
}

variable "region" {
  description = <<-HELP
  Azure region.
  HELP
}
