# Reverse state migration for deployments that used the published module.
#
# This directory previously delegated everything to module.byovpc; it now declares the resources
# directly. These blocks rewrite existing state addresses back out of the module so `terraform
# apply` is a no-op instead of destroying and recreating the VPC, IAM roles and buckets. A block
# whose `from` is absent from state is ignored, so this is safe for a first-time apply too.

moved {
  from = module.byovpc.aws_default_security_group.redpanda
  to   = aws_default_security_group.redpanda
}

moved {
  from = module.byovpc.aws_dynamodb_table.terraform_locks
  to   = aws_dynamodb_table.terraform_locks
}

moved {
  from = module.byovpc.aws_eip.nat_gateway
  to   = aws_eip.nat_gateway
}

moved {
  from = module.byovpc.aws_iam_instance_profile.connectors_node_group
  to   = aws_iam_instance_profile.connectors_node_group
}

moved {
  from = module.byovpc.aws_iam_instance_profile.redpanda_agent
  to   = aws_iam_instance_profile.redpanda_agent
}

moved {
  from = module.byovpc.aws_iam_instance_profile.redpanda_connect_node_group
  to   = aws_iam_instance_profile.redpanda_connect_node_group
}

moved {
  from = module.byovpc.aws_iam_instance_profile.redpanda_node_group
  to   = aws_iam_instance_profile.redpanda_node_group
}

moved {
  from = module.byovpc.aws_iam_instance_profile.rpsql_node_group
  to   = aws_iam_instance_profile.rpsql_node_group
}

moved {
  from = module.byovpc.aws_iam_instance_profile.utility
  to   = aws_iam_instance_profile.utility
}

moved {
  from = module.byovpc.aws_iam_policy.agent_permission_boundary
  to   = aws_iam_policy.agent_permission_boundary
}

moved {
  from = module.byovpc.aws_iam_policy.aws_ebs_csi_driver_policy
  to   = aws_iam_policy.aws_ebs_csi_driver_policy
}

moved {
  from = module.byovpc.aws_iam_policy.byovpc_rpk_user_1
  to   = aws_iam_policy.byovpc_rpk_user_1
}

moved {
  from = module.byovpc.aws_iam_policy.byovpc_rpk_user_2
  to   = aws_iam_policy.byovpc_rpk_user_2
}

moved {
  from = module.byovpc.aws_iam_policy.cert_manager
  to   = aws_iam_policy.cert_manager
}

moved {
  from = module.byovpc.aws_iam_policy.cluster_autoscaler_policy
  to   = aws_iam_policy.cluster_autoscaler_policy
}

moved {
  from = module.byovpc.aws_iam_policy.external_dns_policy
  to   = aws_iam_policy.external_dns_policy
}

moved {
  from = module.byovpc.aws_iam_policy.glue_iceberg
  to   = aws_iam_policy.glue_iceberg
}

moved {
  from = module.byovpc.aws_iam_policy.load_balancer_controller_policy
  to   = aws_iam_policy.load_balancer_controller_policy
}

moved {
  from = module.byovpc.aws_iam_policy.redpanda_agent
  to   = aws_iam_policy.redpanda_agent
}

moved {
  from = module.byovpc.aws_iam_policy.redpanda_agent_private_link
  to   = aws_iam_policy.redpanda_agent_private_link
}

moved {
  from = module.byovpc.aws_iam_role.connectors_node_group
  to   = aws_iam_role.connectors_node_group
}

moved {
  from = module.byovpc.aws_iam_role.k8s_cluster
  to   = aws_iam_role.k8s_cluster
}

moved {
  from = module.byovpc.aws_iam_role.redpanda_agent
  to   = aws_iam_role.redpanda_agent
}

moved {
  from = module.byovpc.aws_iam_role.redpanda_connect_node_group
  to   = aws_iam_role.redpanda_connect_node_group
}

moved {
  from = module.byovpc.aws_iam_role.redpanda_node_group
  to   = aws_iam_role.redpanda_node_group
}

moved {
  from = module.byovpc.aws_iam_role.redpanda_utility_node_group
  to   = aws_iam_role.redpanda_utility_node_group
}

moved {
  from = module.byovpc.aws_iam_role.rpsql_node_group
  to   = aws_iam_role.rpsql_node_group
}

moved {
  from = module.byovpc.aws_iam_role_policy_attachment.connectors_node_group
  to   = aws_iam_role_policy_attachment.connectors_node_group
}

moved {
  from = module.byovpc.aws_iam_role_policy_attachment.external_dns_utility_nodes
  to   = aws_iam_role_policy_attachment.external_dns_utility_nodes
}

moved {
  from = module.byovpc.aws_iam_role_policy_attachment.k8s_cluster
  to   = aws_iam_role_policy_attachment.k8s_cluster
}

moved {
  from = module.byovpc.aws_iam_role_policy_attachment.redpanda_agent
  to   = aws_iam_role_policy_attachment.redpanda_agent
}

moved {
  from = module.byovpc.aws_iam_role_policy_attachment.redpanda_agent_private_link
  to   = aws_iam_role_policy_attachment.redpanda_agent_private_link
}

moved {
  from = module.byovpc.aws_iam_role_policy_attachment.redpanda_connect_node_group
  to   = aws_iam_role_policy_attachment.redpanda_connect_node_group
}

moved {
  from = module.byovpc.aws_iam_role_policy_attachment.redpanda_node_group
  to   = aws_iam_role_policy_attachment.redpanda_node_group
}

moved {
  from = module.byovpc.aws_iam_role_policy_attachment.rpsql_node_group
  to   = aws_iam_role_policy_attachment.rpsql_node_group
}

moved {
  from = module.byovpc.aws_internet_gateway.redpanda
  to   = aws_internet_gateway.redpanda
}

moved {
  from = module.byovpc.aws_main_route_table_association.vpc-main-route-table
  to   = aws_main_route_table_association.vpc-main-route-table
}

moved {
  from = module.byovpc.aws_nat_gateway.redpanda
  to   = aws_nat_gateway.redpanda
}

moved {
  from = module.byovpc.aws_route.nat
  to   = aws_route.nat
}

moved {
  from = module.byovpc.aws_route.public
  to   = aws_route.public
}

moved {
  from = module.byovpc.aws_route_table.main
  to   = aws_route_table.main
}

moved {
  from = module.byovpc.aws_route_table.private
  to   = aws_route_table.private
}

moved {
  from = module.byovpc.aws_route_table_association.private
  to   = aws_route_table_association.private
}

moved {
  from = module.byovpc.aws_route_table_association.public
  to   = aws_route_table_association.public
}

moved {
  from = module.byovpc.aws_s3_bucket.management
  to   = aws_s3_bucket.management
}

moved {
  from = module.byovpc.aws_s3_bucket.redpanda_cloud_storage
  to   = aws_s3_bucket.redpanda_cloud_storage
}

moved {
  from = module.byovpc.aws_s3_bucket.rpsql
  to   = aws_s3_bucket.rpsql
}

moved {
  from = module.byovpc.aws_s3_bucket_ownership_controls.management
  to   = aws_s3_bucket_ownership_controls.management
}

moved {
  from = module.byovpc.aws_s3_bucket_ownership_controls.redpanda_cloud_storage
  to   = aws_s3_bucket_ownership_controls.redpanda_cloud_storage
}

moved {
  from = module.byovpc.aws_s3_bucket_ownership_controls.rpsql
  to   = aws_s3_bucket_ownership_controls.rpsql
}

moved {
  from = module.byovpc.aws_s3_bucket_policy.read_replicas
  to   = aws_s3_bucket_policy.read_replicas
}

moved {
  from = module.byovpc.aws_s3_bucket_public_access_block.rpsql
  to   = aws_s3_bucket_public_access_block.rpsql
}

moved {
  from = module.byovpc.aws_s3_bucket_server_side_encryption_configuration.management
  to   = aws_s3_bucket_server_side_encryption_configuration.management
}

moved {
  from = module.byovpc.aws_s3_bucket_server_side_encryption_configuration.redpanda_cloud_storage
  to   = aws_s3_bucket_server_side_encryption_configuration.redpanda_cloud_storage
}

moved {
  from = module.byovpc.aws_s3_bucket_server_side_encryption_configuration.rpsql
  to   = aws_s3_bucket_server_side_encryption_configuration.rpsql
}

moved {
  from = module.byovpc.aws_s3_bucket_versioning.management
  to   = aws_s3_bucket_versioning.management
}

moved {
  from = module.byovpc.aws_s3_bucket_versioning.redpanda_cloud_storage
  to   = aws_s3_bucket_versioning.redpanda_cloud_storage
}

moved {
  from = module.byovpc.aws_s3_bucket_versioning.rpsql
  to   = aws_s3_bucket_versioning.rpsql
}

moved {
  from = module.byovpc.aws_security_group.cluster
  to   = aws_security_group.cluster
}

moved {
  from = module.byovpc.aws_security_group.connectors
  to   = aws_security_group.connectors
}

moved {
  from = module.byovpc.aws_security_group.node
  to   = aws_security_group.node
}

moved {
  from = module.byovpc.aws_security_group.redpanda_agent
  to   = aws_security_group.redpanda_agent
}

moved {
  from = module.byovpc.aws_security_group.redpanda_connect
  to   = aws_security_group.redpanda_connect
}

moved {
  from = module.byovpc.aws_security_group.redpanda_node_group
  to   = aws_security_group.redpanda_node_group
}

moved {
  from = module.byovpc.aws_security_group.rpsql
  to   = aws_security_group.rpsql
}

moved {
  from = module.byovpc.aws_security_group.utility
  to   = aws_security_group.utility
}

moved {
  from = module.byovpc.aws_security_group_rule.cluster_agent_to_cluster_api
  to   = aws_security_group_rule.cluster_agent_to_cluster_api
}

moved {
  from = module.byovpc.aws_security_group_rule.cluster_api_to_node_group
  to   = aws_security_group_rule.cluster_api_to_node_group
}

moved {
  from = module.byovpc.aws_security_group_rule.cluster_api_to_node_groups
  to   = aws_security_group_rule.cluster_api_to_node_groups
}

moved {
  from = module.byovpc.aws_security_group_rule.cluster_api_to_node_kubelets
  to   = aws_security_group_rule.cluster_api_to_node_kubelets
}

moved {
  from = module.byovpc.aws_security_group_rule.cluster_egress_nodes_kubelet
  to   = aws_security_group_rule.cluster_egress_nodes_kubelet
}

moved {
  from = module.byovpc.aws_security_group_rule.cluster_node_groups_to_cluster_api
  to   = aws_security_group_rule.cluster_node_groups_to_cluster_api
}

moved {
  from = module.byovpc.aws_security_group_rule.connectors
  to   = aws_security_group_rule.connectors
}

moved {
  from = module.byovpc.aws_security_group_rule.egress_all_https_to_internet
  to   = aws_security_group_rule.egress_all_https_to_internet
}

moved {
  from = module.byovpc.aws_security_group_rule.egress_ntp_tcp_to_internet
  to   = aws_security_group_rule.egress_ntp_tcp_to_internet
}

moved {
  from = module.byovpc.aws_security_group_rule.egress_ntp_udp_to_internet
  to   = aws_security_group_rule.egress_ntp_udp_to_internet
}

moved {
  from = module.byovpc.aws_security_group_rule.node_groups_to_cluster_api
  to   = aws_security_group_rule.node_groups_to_cluster_api
}

moved {
  from = module.byovpc.aws_security_group_rule.node_to_node_coredns
  to   = aws_security_group_rule.node_to_node_coredns
}

moved {
  from = module.byovpc.aws_security_group_rule.node_to_node_coredns_egress
  to   = aws_security_group_rule.node_to_node_coredns_egress
}

moved {
  from = module.byovpc.aws_security_group_rule.node_to_node_coredns_udp
  to   = aws_security_group_rule.node_to_node_coredns_udp
}

moved {
  from = module.byovpc.aws_security_group_rule.node_to_node_coredns_udp_egress
  to   = aws_security_group_rule.node_to_node_coredns_udp_egress
}

moved {
  from = module.byovpc.aws_security_group_rule.redpanda_connect
  to   = aws_security_group_rule.redpanda_connect
}

moved {
  from = module.byovpc.aws_security_group_rule.redpanda_node_group
  to   = aws_security_group_rule.redpanda_node_group
}

moved {
  from = module.byovpc.aws_security_group_rule.redpanda_node_group_public_dual
  to   = aws_security_group_rule.redpanda_node_group_public_dual
}

moved {
  from = module.byovpc.aws_security_group_rule.rpsql
  to   = aws_security_group_rule.rpsql
}

moved {
  from = module.byovpc.aws_security_group_rule.rpsql_ingress_data
  to   = aws_security_group_rule.rpsql_ingress_data
}

moved {
  from = module.byovpc.aws_security_group_rule.rpsql_ingress_healthcheck
  to   = aws_security_group_rule.rpsql_ingress_healthcheck
}

moved {
  from = module.byovpc.aws_security_group_rule.utility
  to   = aws_security_group_rule.utility
}

moved {
  from = module.byovpc.aws_subnet.private
  to   = aws_subnet.private
}

moved {
  from = module.byovpc.aws_subnet.public
  to   = aws_subnet.public
}

moved {
  from = module.byovpc.aws_vpc.redpanda
  to   = aws_vpc.redpanda
}

moved {
  from = module.byovpc.aws_vpc_endpoint.s3
  to   = aws_vpc_endpoint.s3
}

moved {
  from = module.byovpc.aws_vpc_endpoint_route_table_association.private_s3
  to   = aws_vpc_endpoint_route_table_association.private_s3
}

moved {
  from = module.byovpc.aws_vpc_endpoint_route_table_association.public_s3
  to   = aws_vpc_endpoint_route_table_association.public_s3
}

moved {
  from = module.byovpc.null_resource.eks_nodegroup_service_linked_role
  to   = null_resource.eks_nodegroup_service_linked_role
}

moved {
  from = module.byovpc.random_shuffle.az
  to   = random_shuffle.az
}

moved {
  from = module.byovpc.random_string.unique_id
  to   = random_string.unique_id
}

moved {
  from = module.byovpc.terraform_data.dual_requires_public_ip_on_launch
  to   = terraform_data.dual_requires_public_ip_on_launch
}

moved {
  from = module.byovpc.terraform_data.dual_requires_public_subnet_per_az
  to   = terraform_data.dual_requires_public_subnet_per_az
}

moved {
  from = module.byovpc.terraform_data.public_subnets_not_both
  to   = terraform_data.public_subnets_not_both
}
