###########################################################################
# IAM vars
###########################################################################
variable "redpanda_agent_role_name" {
  type        = string
  default     = "agent-role"
  description = <<-HELP
    The role name of Redpanda agent.
  HELP
}

variable "redpanda_console_role_name" {
  type        = string
  default     = "console-role"
  description = <<-HELP
    The role name of Redpanda Console.
  HELP
}

variable "redpanda_private_link_role_name" {
  type        = string
  default     = "private-link-role"
  description = <<-HELP
    The role name of Redpanda private link.
  HELP
}
