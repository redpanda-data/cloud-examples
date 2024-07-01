output "redpanda_agent_role_arn" {
  value = aws_iam_role.redpanda_agent.arn
}

output "connectors_node_group_instance_profile_arn" {
  value = aws_iam_instance_profile.connectors_node_group.arn
}

output "utility_node_group_instance_profile_arn" {
  value = aws_iam_instance_profile.utility.arn
}

output "redpanda_node_group_instance_profile_arn" {
  value = aws_iam_instance_profile.redpanda_node_group.arn
}

output "k8s_cluster_role_arn" {
  value = aws_iam_role.k8s_cluster.arn
}

output "console_secrets_manager_role_arn" {
  value = aws_iam_role.console_secrets_manager_redpanda.arn
}

output "redpanda_cloud_storage_manager_role_arn" {
  value = aws_iam_role.redpanda_cloud_storage_manager.arn
}

output "agent_instance_profile_arn" {
  value = aws_iam_instance_profile.redpanda_agent.arn
}

output "connectors_secrets_manager_role_arn" {
  value = aws_iam_role.connectors_secrets_manager.arn
}

output "cloud_storage_bucket_arn" {
  value = aws_s3_bucket.redpanda_cloud_storage.arn
}

output "management_bucket_arn" {
  value = aws_s3_bucket.management.arn
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.terraform_locks.arn
}

output "vpc_arn" {
  value = aws_vpc.redpanda.arn
}

output "public_subnet_ids" {
  value       = jsonencode(aws_subnet.public[*].arn)
  description = "Public subnets IDs created"
}

output "private_subnet_ids" {
  value       = jsonencode(aws_subnet.private[*].arn)
  description = "Private subnet IDs created"
}

output "redpanda_agent_security_group_arn" {
  value       = aws_security_group.redpanda_agent.arn
  description = "ID of the redpanda agent security group"
}

output "connectors_security_group_arn" {
  value       = aws_security_group.connectors.arn
  description = "Connectors security group ARN"
}

output "redpanda_node_group_security_group_arn" {
  value       = aws_security_group.redpanda_node_group.arn
  description = "Redpanda Node Group security group ARN"
}

output "utility_security_group_arn" {
  value       = aws_security_group.utility.arn
  description = "Utility security group ARN"
}

output "cluster_security_group_arn" {
  value       = aws_security_group.cluster.arn
  description = "EKS cluster security group"
}

output "node_security_group_arn" {
  value       = aws_security_group.node.arn
  description = "EKS node shared security group"
}

output "byovpc_rpk_user_policy_arns" {
  value       = values(aws_iam_policy.byovpc_rpk_user)[*].arn
  description = "ARNs of policies associated with the 'rpk user'. Can be used by Redpanda engineers to the assume the role and test provisioning with more limited access."
}
