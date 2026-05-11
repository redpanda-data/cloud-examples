variable "region" {
  type        = string
  default     = "us-east-2"
  description = "AWS region where the hub VPC and TGW will be created."
}

variable "common_prefix" {
  type        = string
  default     = "hub"
  description = "Prefix applied to all resource names."
}

variable "vpc_cidr" {
  type    = string
  default = "100.64.0.0/16"
  description = <<-HELP
  CIDR for the hub/egress VPC.
  MUST NOT overlap with any spoke VPC CIDRs — TGW routing breaks silently when CIDRs
  collide because the route table can only hold one entry per prefix.
  100.64.0.0/16 (CGNAT range) is a safe default: it is not routable on the public
  internet and is unlikely to be used by spoke VPCs.
  HELP
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["100.64.0.0/24", "100.64.1.0/24"]
  description = "CIDRs for public subnets (one per AZ). NAT Gateway lives here. Must be within vpc_cidr."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["100.64.2.0/24", "100.64.3.0/24"]
  description = "CIDRs for private subnets (one per AZ). TGW attachment lives here. Must be within vpc_cidr."
}

variable "spoke_cidrs" {
  type = list(string)
  default = ["10.0.0.0/16"]
  description = <<-HELP
  CIDRs of all spoke VPCs that will attach to this TGW.
  Used to install return routes in the hub's public subnet so NAT Gateway replies
  are forwarded back to the correct spoke via TGW.
  Must match the actual VPC CIDRs used by the Redpanda BYOC clusters — a mismatch
  here (e.g. 172.16.0.0/16 when the cluster uses 10.0.0.0/16) is the most common
  cause of one-way connectivity (egress works, replies are dropped).
  Must not overlap with vpc_cidr.
  HELP
}

variable "redpanda_aws_account_id" {
  type        = string
  default     = "472797112831"
  description = <<-HELP
  Redpanda's AWS account ID. The TGW will be shared with this account via RAM so
  Redpanda can attach the BYOC spoke VPC to it.
  HELP
}

variable "default_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources."
}
