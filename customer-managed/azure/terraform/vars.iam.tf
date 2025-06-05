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

variable "kafka_connect_role_name" {
  type        = string
  default     = "kafka-connect-role"
  description = <<-HELP
    The role name of Kafka Connect.
  HELP
}

variable "redpanda_connect_role_name" {
  type        = string
  default     = "redpanda-connect-role"
  description = <<-HELP
    The role name of Redpanda Connect.
  HELP
}

variable "redpanda_connect_api_role_name" {
  type        = string
  default     = "redpanda-connect-api-role"
  description = <<-HELP
    The role name of Redpanda Connect API.
  HELP
}

variable "redpanda_cluster_role_name" {
  type        = string
  default     = "redpanda-cluster-role"
  description = <<-HELP
    The role name of Redpanda cluster.
  HELP
}

variable "redpanda_operator_role_name" {
  type        = string
  default     = "redpanda-operator-role"
  description = <<-HELP
    The role name of Redpanda operator.
  HELP
}
