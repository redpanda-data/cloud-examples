resource "aws_security_group" "redpanda_agent" {
  name_prefix = "${var.common_prefix}agent-"
  description = "Redpanda agent VM"
  vpc_id      = aws_vpc.redpanda.id
  ingress     = []
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "connectors" {
  name_prefix = "${var.common_prefix}connect-"
  description = "Redpanda connectors nodes"
  vpc_id      = aws_vpc.redpanda.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "connectors" {
  security_group_id = aws_security_group.connectors.id
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  type              = "egress"
  description       = "Allow all egress traffic"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "utility" {
  name_prefix = "${var.common_prefix}util-"
  description = "Redpanda utility nodes"
  vpc_id      = aws_vpc.redpanda.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "utility" {
  security_group_id = aws_security_group.utility.id
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  type              = "egress"
  description       = "Allow all egress traffic"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "redpanda_node_group" {
  name_prefix = "${var.common_prefix}rp-"
  description = "Redpanda cluster nodes"
  vpc_id      = aws_vpc.redpanda.id
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  rp_node_group_cidr_blocks = var.public_cluster ? [
    "0.0.0.0/0"
    ] : [
    "100.64.0.0/10",
    "172.16.0.0/12",
    "192.168.0.0/16",
    "10.0.0.0/8",
  ]
}
resource "aws_security_group_rule" "redpanda_node_group" {
  security_group_id = aws_security_group.redpanda_node_group.id
  protocol          = "tcp"
  from_port         = 30092
  to_port           = 30094
  type              = "ingress"
  description       = "Allow access to Kafka API in the ports advertised by Redpanda brokers"
  cidr_blocks       = local.rp_node_group_cidr_blocks
}

locals {
  cluster_security_group_rules = {
    ingress_nodes_443 = {
      description                = "Node groups to cluster API"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      source_node_security_group = true
    }
    ingress_nodes_from_agent_443 = {
      description = "Agent to cluster API"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [aws_vpc.redpanda.cidr_block]
    }
    egress_nodes_443 = {
      description                = "Cluster API to node groups"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "egress"
      source_node_security_group = true
    }
    egress_nodes_kubelet = {
      description                = "Cluster API to node kubelets"
      protocol                   = "tcp"
      from_port                  = 10250
      to_port                    = 10250
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_id = aws_security_group.node.id
}
resource "aws_security_group" "cluster" {
  name_prefix = "${var.common_prefix}cluster-"
  description = "EKS cluster security group"
  vpc_id      = aws_vpc.redpanda.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "cluster" {
  for_each = { for k, v in local.cluster_security_group_rules : k => v }

  security_group_id = aws_security_group.cluster.id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type
  description       = try(each.value.description, null)
  cidr_blocks       = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks  = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids   = try(each.value.prefix_list_ids, [])
  self              = try(each.value.self, null)
  source_security_group_id = try(
    each.value.source_security_group_id,
    try(each.value.source_node_security_group, false) ? local.node_security_group_id : null
  )
}

locals {
  node_security_group_rules = {
    egress_cluster_443 = {
      description                   = "Node groups to cluster API"
      protocol                      = "tcp"
      from_port                     = 443
      to_port                       = 443
      type                          = "egress"
      source_cluster_security_group = true
    }
    ingress_cluster_443 = {
      description                   = "Cluster API to node groups"
      protocol                      = "tcp"
      from_port                     = 443
      to_port                       = 443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_cluster_kubelet = {
      description                   = "Cluster API to node kubelets"
      protocol                      = "tcp"
      from_port                     = 10250
      to_port                       = 10250
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_self_coredns_tcp = {
      description = "Node to node CoreDNS"
      protocol    = "tcp"
      from_port   = 53
      to_port     = 53
      type        = "ingress"
      self        = true
    }
    egress_self_coredns_tcp = {
      description = "Node to node CoreDNS"
      protocol    = "tcp"
      from_port   = 53
      to_port     = 53
      type        = "egress"
      self        = true
    }
    ingress_self_coredns_udp = {
      description = "Node to node CoreDNS"
      protocol    = "udp"
      from_port   = 53
      to_port     = 53
      type        = "ingress"
      self        = true
    }
    egress_self_coredns_udp = {
      description = "Node to node CoreDNS"
      protocol    = "udp"
      from_port   = 53
      to_port     = 53
      type        = "egress"
      self        = true
    }
    egress_https = {
      description = "Egress all HTTPS to internet"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_ntp_tcp = {
      description = "Egress NTP/TCP to internet"
      protocol    = "tcp"
      from_port   = 123
      to_port     = 123
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_ntp_udp = {
      description = "Egress NTP/UDP to internet"
      protocol    = "udp"
      from_port   = 123
      to_port     = 123
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  cluster_security_group_id = aws_security_group.cluster.id
}
resource "aws_security_group" "node" {
  name_prefix = "${var.common_prefix}node-"
  description = "EKS node shared security group"
  vpc_id      = aws_vpc.redpanda.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "node" {
  for_each = { for k, v in local.node_security_group_rules : k => v }

  # Required
  security_group_id = aws_security_group.node.id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type

  # Optional
  description      = try(each.value.description, null)
  cidr_blocks      = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids  = try(each.value.prefix_list_ids, [])
  self             = try(each.value.self, null)
  source_security_group_id = try(
    each.value.source_security_group_id,
    try(each.value.source_cluster_security_group, false) ? local.cluster_security_group_id : null
  )
}
