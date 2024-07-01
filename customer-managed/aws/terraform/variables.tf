variable "region" {
  type        = string
  description = <<-HELP
  The region where the VPC lives. Required.
  HELP
}

variable "aws_account_id" {
  type        = string
  default     = ""
  description = <<-HELP
  The AWS account ID where the Redpanda cluster will live. If not set, the
  account ID of the underlying Terraform run STS identity will be used.
  HELP
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.3.0/24",
    "10.0.5.0/24",
    "10.0.7.0/24",
    "10.0.9.0/24",
    "10.0.11.0/24"
  ]
  description = <<-HELP
  One public subnet will be created per cidr in this list.
  HELP
}

variable "private_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.0.0/24",
    "10.0.2.0/24",
    "10.0.4.0/24",
    "10.0.6.0/24",
    "10.0.8.0/24",
    "10.0.10.0/24"
  ]
  description = <<-HELP
  One private subnet will be created per cidr in this list.
  HELP
}

variable "zones" {
  type = list(string)
  default = [
    "use2-az1",
    "use2-az2",
    "use2-az3"
  ]
  description = <<-HELP
  The Availability Zone IDs to assign to the subnets, will be round-robined for each public and private subnet cidr.
  HELP
}

variable "public_cluster" {
  type        = bool
  default     = false
  description = <<-HELP
  When true the security groups will be configured in a way to allow public ingress to redpanda. When false ingress will
  be restricted to internal addresses.
  HELP
}

variable "condition_tags" {
  type = map(string)
  default = {
    "redpanda-managed" : "true",
  }
  description = <<-HELP
  Map of tag key/value pairs that will be included as conditional constraints on IAM resources. The redpanda-managed:true
  is a tag that the Redpanda logic applies to all resources it creates during both bootstrap (byoc apply) and provisioning.
  It is also recommended that you include a unique cloud provider tag on your cluster during cluster creation and then
  also include that tag here, this will constrain these resources to be available only to those IAM policies used by
  that cluster. (Please keep in mind that if you choose this route you should not remove or modify the unique cloud
  provider tag on the cluster unless you first remove it here.)
  HELP
}

variable "default_tags" {
  type        = map(string)
  default     = {}
  description = <<-HELP
  Map of keys and values that will be applied as tags to all resources
  HELP
}

variable "enable_private_link" {
  type        = bool
  default     = false
  description = <<-HELP
  When true grants additional permissions required by Private Link. https://docs.redpanda.com/current/deploy/deployment-option/cloud/aws-privatelink/
  HELP
}

variable "common_prefix" {
  type        = string
  default     = "redpanda-"
  description = <<-HELP
  Text to be included at the start of the name prefix on any objects supporting name prefixes.
  HELP
}
