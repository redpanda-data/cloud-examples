output "redpanda_agent_role_arn" {
  value = module.byovpc.redpanda_agent_role_arn
}

output "agent_instance_profile_arn" {
  value = module.byovpc.agent_instance_profile_arn
}

output "k8s_cluster_role_arn" {
  value = module.byovpc.k8s_cluster_role_arn
}

output "redpanda_node_group_instance_profile_arn" {
  value = module.byovpc.redpanda_node_group_instance_profile_arn
}

output "connectors_node_group_instance_profile_arn" {
  value = module.byovpc.connectors_node_group_instance_profile_arn
}

output "redpanda_connect_node_group_instance_profile_arn" {
  value = module.byovpc.redpanda_connect_node_group_instance_profile_arn
}

output "utility_node_group_instance_profile_arn" {
  value = module.byovpc.utility_node_group_instance_profile_arn
}

output "cloud_storage_bucket_arn" {
  value = module.byovpc.cloud_storage_bucket_arn
}

output "management_bucket_arn" {
  value = module.byovpc.management_bucket_arn
}

output "dynamodb_table_arn" {
  value = module.byovpc.dynamodb_table_arn
}

output "vpc_arn" {
  value = module.byovpc.vpc_arn
}

output "private_subnet_ids" {
  value       = module.byovpc.private_subnet_ids
  description = "Private subnet ARNs (JSON-encoded list)."
}

output "private_subnet_arns" {
  value       = module.byovpc.private_subnet_arns
  description = "List of private subnet ARNs."
}

output "redpanda_agent_security_group_arn" {
  value       = module.byovpc.redpanda_agent_security_group_arn
  description = "ARN of the redpanda agent security group."
}

output "connectors_security_group_arn" {
  value       = module.byovpc.connectors_security_group_arn
  description = "Connectors security group ARN."
}

output "redpanda_connect_security_group_arn" {
  value       = module.byovpc.redpanda_connect_security_group_arn
  description = "Redpanda Connect security group ARN."
}

output "redpanda_node_group_security_group_arn" {
  value       = module.byovpc.redpanda_node_group_security_group_arn
  description = "Redpanda node group security group ARN."
}

output "utility_security_group_arn" {
  value       = module.byovpc.utility_security_group_arn
  description = "Utility security group ARN."
}

output "cluster_security_group_arn" {
  value       = module.byovpc.cluster_security_group_arn
  description = "EKS cluster security group ARN."
}

output "node_security_group_arn" {
  value       = module.byovpc.node_security_group_arn
  description = "EKS node shared security group ARN."
}

output "byovpc_rpk_user_policy_arns" {
  value       = module.byovpc.byovpc_rpk_user_policy_arns
  description = "ARNs of policies associated with the 'rpk user'. Can be assumed by Redpanda engineers to test provisioning with reduced access."
}

output "permissions_boundary_policy_arn" {
  value       = module.byovpc.permissions_boundary_policy_arn
  description = "ARN of the permissions boundary that must be included on any roles created by the Redpanda agent."
}
