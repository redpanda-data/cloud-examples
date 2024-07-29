variable "create_role_assignment" {
  type        = bool
  default     = true
  description = <<-HELP
    Whether to create role assigments.
  HELP
}

variable "create_nat" {
  type        = bool
  default     = true
  description = <<-HELP
  Whether to create NAT gateway and its assoications
  HELP
}

