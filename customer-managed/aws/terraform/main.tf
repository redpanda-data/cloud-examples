module "byovpc" {
  source  = "redpanda-data/redpanda-byovpc/aws"
  version = "~> 2.1"

  region         = var.region
  aws_account_id = var.aws_account_id
  common_prefix  = var.common_prefix

  vpc_id                   = var.vpc_id
  vpc_cidr_block           = var.vpc_cidr_block
  zones                    = var.zones
  private_subnet_cidrs     = var.private_subnet_cidrs
  private_subnet_ids       = var.private_subnet_ids
  public_subnet_cidrs      = var.public_subnet_cidrs
  network_exclude_zone_ids = var.network_exclude_zone_ids

  condition_tags = var.condition_tags
  default_tags   = var.default_tags
  ignore_tags    = var.ignore_tags

  enable_private_link                      = var.enable_private_link
  enable_redpanda_connect                  = var.enable_redpanda_connect
  create_internet_gateway                  = var.create_internet_gateway
  create_rpk_user                          = var.create_rpk_user
  create_eks_nodegroup_service_linked_role = var.create_eks_nodegroup_service_linked_role
  force_destroy_cloud_storage              = var.force_destroy_cloud_storage

  source_cluster_bucket_names = var.source_cluster_bucket_names
  reader_cluster_id           = var.reader_cluster_id
}

# State migration for deployments that pre-date the module refactor.
# Every resource previously declared in this directory is now created by
# module.byovpc; these `moved` blocks rewrite existing state addresses so
# `terraform apply` is a no-op instead of a destroy/recreate.

moved {
  from = aws_default_security_group.redpanda
  to   = module.byovpc.aws_default_security_group.redpanda
}

moved {
  from = aws_dynamodb_table.terraform_locks
  to   = module.byovpc.aws_dynamodb_table.terraform_locks
}

moved {
  from = aws_eip.nat_gateway
  to   = module.byovpc.aws_eip.nat_gateway
}

moved {
  from = aws_iam_instance_profile.connectors_node_group
  to   = module.byovpc.aws_iam_instance_profile.connectors_node_group
}

moved {
  from = aws_iam_instance_profile.redpanda_agent
  to   = module.byovpc.aws_iam_instance_profile.redpanda_agent
}

moved {
  from = aws_iam_instance_profile.redpanda_connect_node_group
  to   = module.byovpc.aws_iam_instance_profile.redpanda_connect_node_group
}

moved {
  from = aws_iam_instance_profile.redpanda_node_group
  to   = module.byovpc.aws_iam_instance_profile.redpanda_node_group
}

moved {
  from = aws_iam_instance_profile.utility
  to   = module.byovpc.aws_iam_instance_profile.utility
}

moved {
  from = aws_iam_policy.agent_permission_boundary
  to   = module.byovpc.aws_iam_policy.agent_permission_boundary
}

moved {
  from = aws_iam_policy.aws_ebs_csi_driver_policy
  to   = module.byovpc.aws_iam_policy.aws_ebs_csi_driver_policy
}

moved {
  from = aws_iam_policy.byovpc_rpk_user_1
  to   = module.byovpc.aws_iam_policy.byovpc_rpk_user_1
}

moved {
  from = aws_iam_policy.byovpc_rpk_user_2
  to   = module.byovpc.aws_iam_policy.byovpc_rpk_user_2
}

moved {
  from = aws_iam_policy.cert_manager
  to   = module.byovpc.aws_iam_policy.cert_manager
}

moved {
  from = aws_iam_policy.cluster_autoscaler_policy
  to   = module.byovpc.aws_iam_policy.cluster_autoscaler_policy
}

moved {
  from = aws_iam_policy.external_dns_policy
  to   = module.byovpc.aws_iam_policy.external_dns_policy
}

moved {
  from = aws_iam_policy.load_balancer_controller_policy
  to   = module.byovpc.aws_iam_policy.load_balancer_controller_policy
}

moved {
  from = aws_iam_policy.redpanda_agent
  to   = module.byovpc.aws_iam_policy.redpanda_agent
}

moved {
  from = aws_iam_policy.redpanda_agent_private_link
  to   = module.byovpc.aws_iam_policy.redpanda_agent_private_link
}

moved {
  from = aws_iam_role.connectors_node_group
  to   = module.byovpc.aws_iam_role.connectors_node_group
}

moved {
  from = aws_iam_role.k8s_cluster
  to   = module.byovpc.aws_iam_role.k8s_cluster
}

moved {
  from = aws_iam_role.redpanda_agent
  to   = module.byovpc.aws_iam_role.redpanda_agent
}

moved {
  from = aws_iam_role.redpanda_connect_node_group
  to   = module.byovpc.aws_iam_role.redpanda_connect_node_group
}

moved {
  from = aws_iam_role.redpanda_node_group
  to   = module.byovpc.aws_iam_role.redpanda_node_group
}

moved {
  from = aws_iam_role.redpanda_utility_node_group
  to   = module.byovpc.aws_iam_role.redpanda_utility_node_group
}

moved {
  from = aws_iam_role_policy_attachment.connectors_node_group
  to   = module.byovpc.aws_iam_role_policy_attachment.connectors_node_group
}

moved {
  from = aws_iam_role_policy_attachment.external_dns_utility_nodes
  to   = module.byovpc.aws_iam_role_policy_attachment.external_dns_utility_nodes
}

moved {
  from = aws_iam_role_policy_attachment.k8s_cluster
  to   = module.byovpc.aws_iam_role_policy_attachment.k8s_cluster
}

moved {
  from = aws_iam_role_policy_attachment.redpanda_agent
  to   = module.byovpc.aws_iam_role_policy_attachment.redpanda_agent
}

moved {
  from = aws_iam_role_policy_attachment.redpanda_agent_private_link
  to   = module.byovpc.aws_iam_role_policy_attachment.redpanda_agent_private_link
}

moved {
  from = aws_iam_role_policy_attachment.redpanda_connect_node_group
  to   = module.byovpc.aws_iam_role_policy_attachment.redpanda_connect_node_group
}

moved {
  from = aws_iam_role_policy_attachment.redpanda_node_group
  to   = module.byovpc.aws_iam_role_policy_attachment.redpanda_node_group
}

moved {
  from = aws_internet_gateway.redpanda
  to   = module.byovpc.aws_internet_gateway.redpanda
}

moved {
  from = aws_main_route_table_association.vpc-main-route-table
  to   = module.byovpc.aws_main_route_table_association.vpc-main-route-table
}

moved {
  from = aws_nat_gateway.redpanda
  to   = module.byovpc.aws_nat_gateway.redpanda
}

moved {
  from = aws_route.nat
  to   = module.byovpc.aws_route.nat
}

moved {
  from = aws_route.public
  to   = module.byovpc.aws_route.public
}

moved {
  from = aws_route_table.main
  to   = module.byovpc.aws_route_table.main
}

moved {
  from = aws_route_table.private
  to   = module.byovpc.aws_route_table.private
}

moved {
  from = aws_route_table_association.private
  to   = module.byovpc.aws_route_table_association.private
}

moved {
  from = aws_route_table_association.public
  to   = module.byovpc.aws_route_table_association.public
}

moved {
  from = aws_s3_bucket.management
  to   = module.byovpc.aws_s3_bucket.management
}

moved {
  from = aws_s3_bucket.redpanda_cloud_storage
  to   = module.byovpc.aws_s3_bucket.redpanda_cloud_storage
}

moved {
  from = aws_s3_bucket_ownership_controls.management
  to   = module.byovpc.aws_s3_bucket_ownership_controls.management
}

moved {
  from = aws_s3_bucket_ownership_controls.redpanda_cloud_storage
  to   = module.byovpc.aws_s3_bucket_ownership_controls.redpanda_cloud_storage
}

moved {
  from = aws_s3_bucket_policy.read_replicas
  to   = module.byovpc.aws_s3_bucket_policy.read_replicas
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.management
  to   = module.byovpc.aws_s3_bucket_server_side_encryption_configuration.management
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.redpanda_cloud_storage
  to   = module.byovpc.aws_s3_bucket_server_side_encryption_configuration.redpanda_cloud_storage
}

moved {
  from = aws_s3_bucket_versioning.management
  to   = module.byovpc.aws_s3_bucket_versioning.management
}

moved {
  from = aws_s3_bucket_versioning.redpanda_cloud_storage
  to   = module.byovpc.aws_s3_bucket_versioning.redpanda_cloud_storage
}

moved {
  from = aws_security_group.cluster
  to   = module.byovpc.aws_security_group.cluster
}

moved {
  from = aws_security_group.connectors
  to   = module.byovpc.aws_security_group.connectors
}

moved {
  from = aws_security_group.node
  to   = module.byovpc.aws_security_group.node
}

moved {
  from = aws_security_group.redpanda_agent
  to   = module.byovpc.aws_security_group.redpanda_agent
}

moved {
  from = aws_security_group.redpanda_connect
  to   = module.byovpc.aws_security_group.redpanda_connect
}

moved {
  from = aws_security_group.redpanda_node_group
  to   = module.byovpc.aws_security_group.redpanda_node_group
}

moved {
  from = aws_security_group.utility
  to   = module.byovpc.aws_security_group.utility
}

moved {
  from = aws_security_group_rule.cluster_agent_to_cluster_api
  to   = module.byovpc.aws_security_group_rule.cluster_agent_to_cluster_api
}

moved {
  from = aws_security_group_rule.cluster_api_to_node_group
  to   = module.byovpc.aws_security_group_rule.cluster_api_to_node_group
}

moved {
  from = aws_security_group_rule.cluster_api_to_node_groups
  to   = module.byovpc.aws_security_group_rule.cluster_api_to_node_groups
}

moved {
  from = aws_security_group_rule.cluster_api_to_node_kubelets
  to   = module.byovpc.aws_security_group_rule.cluster_api_to_node_kubelets
}

moved {
  from = aws_security_group_rule.cluster_egress_nodes_kubelet
  to   = module.byovpc.aws_security_group_rule.cluster_egress_nodes_kubelet
}

moved {
  from = aws_security_group_rule.cluster_node_groups_to_cluster_api
  to   = module.byovpc.aws_security_group_rule.cluster_node_groups_to_cluster_api
}

moved {
  from = aws_security_group_rule.connectors
  to   = module.byovpc.aws_security_group_rule.connectors
}

moved {
  from = aws_security_group_rule.egress_all_https_to_internet
  to   = module.byovpc.aws_security_group_rule.egress_all_https_to_internet
}

moved {
  from = aws_security_group_rule.egress_ntp_tcp_to_internet
  to   = module.byovpc.aws_security_group_rule.egress_ntp_tcp_to_internet
}

moved {
  from = aws_security_group_rule.egress_ntp_udp_to_internet
  to   = module.byovpc.aws_security_group_rule.egress_ntp_udp_to_internet
}

moved {
  from = aws_security_group_rule.node_groups_to_cluster_api
  to   = module.byovpc.aws_security_group_rule.node_groups_to_cluster_api
}

moved {
  from = aws_security_group_rule.node_to_node_coredns
  to   = module.byovpc.aws_security_group_rule.node_to_node_coredns
}

moved {
  from = aws_security_group_rule.node_to_node_coredns_egress
  to   = module.byovpc.aws_security_group_rule.node_to_node_coredns_egress
}

moved {
  from = aws_security_group_rule.node_to_node_coredns_udp
  to   = module.byovpc.aws_security_group_rule.node_to_node_coredns_udp
}

moved {
  from = aws_security_group_rule.node_to_node_coredns_udp_egress
  to   = module.byovpc.aws_security_group_rule.node_to_node_coredns_udp_egress
}

moved {
  from = aws_security_group_rule.redpanda_connect
  to   = module.byovpc.aws_security_group_rule.redpanda_connect
}

moved {
  from = aws_security_group_rule.redpanda_node_group
  to   = module.byovpc.aws_security_group_rule.redpanda_node_group
}

moved {
  from = aws_security_group_rule.utility
  to   = module.byovpc.aws_security_group_rule.utility
}

moved {
  from = aws_subnet.private
  to   = module.byovpc.aws_subnet.private
}

moved {
  from = aws_subnet.public
  to   = module.byovpc.aws_subnet.public
}

moved {
  from = aws_vpc.redpanda
  to   = module.byovpc.aws_vpc.redpanda
}

moved {
  from = aws_vpc_endpoint.s3
  to   = module.byovpc.aws_vpc_endpoint.s3
}

moved {
  from = aws_vpc_endpoint_route_table_association.private_s3
  to   = module.byovpc.aws_vpc_endpoint_route_table_association.private_s3
}

moved {
  from = aws_vpc_endpoint_route_table_association.public_s3
  to   = module.byovpc.aws_vpc_endpoint_route_table_association.public_s3
}

moved {
  from = null_resource.eks_nodegroup_service_linked_role
  to   = module.byovpc.null_resource.eks_nodegroup_service_linked_role
}

moved {
  from = random_shuffle.az
  to   = module.byovpc.random_shuffle.az
}

moved {
  from = random_string.unique_id
  to   = module.byovpc.random_string.unique_id
}
