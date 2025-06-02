
locals {
  resource_prefix = (var.resource_prefix) == "" ? "" : replace(var.resource_prefix, "_", "-")

  vm_user_data_with_cloud_config_directive = "#cloud-config\n${jsonencode(local.vm_user_data)}"

  client_vpc_id = data.aws_subnet.client.vpc_id
}

resource "aws_security_group" "rp" {
  name        = "${local.resource_prefix}redpanda-sg"
  description = "Redpanda service security group"
  vpc_id      = local.client_vpc_id
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.default.id
}

resource "aws_security_group_rule" "kafka_broker_endpoints" {
  type              = "egress"
  from_port         = 30092
  to_port           = 30093
  cidr_blocks       = [var.rp_vpc_cidr]
  protocol          = "tcp"
  security_group_id = aws_security_group.rp.id
}

resource "aws_security_group_rule" "kafka_seed_endpoint" {
  type              = "egress"
  from_port         = 9092
  to_port           = 9093
  cidr_blocks       = [var.rp_vpc_cidr]
  protocol          = "tcp"
  security_group_id = aws_security_group.rp.id
}

# Include mTLS+SASL ports
resource "aws_security_group_rule" "proxy_schema_endpoints" {
  type              = "egress"
  from_port         = 30080
  to_port           = 30083
  cidr_blocks       = [var.rp_vpc_cidr]
  protocol          = "tcp"
  security_group_id = aws_security_group.rp.id
}

resource "aws_security_group_rule" "console_endpoint" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = [var.rp_vpc_cidr]
  protocol          = "tcp"
  security_group_id = aws_security_group.rp.id
}
resource "tls_private_key" "test" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${local.resource_prefix}${var.rp_id}-sshkey"
  public_key = tls_private_key.test.public_key_openssh
}

resource "random_id" "suffix" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    ami_id = data.aws_ami.ubuntu.id
  }

  byte_length = 4
}

resource "aws_instance" "kafka_test" {
  ami           = random_id.suffix.keepers.ami_id
  instance_type = "t3.nano"

  subnet_id = var.client_subnet_id
  key_name  = aws_key_pair.generated_key.key_name

  user_data_base64 = base64encode(local.vm_user_data_with_cloud_config_directive)
}

resource "aws_eip" "test_instance_eip" {
  instance = aws_instance.kafka_test.id
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = local.client_vpc_id
}

resource "aws_route_table" "route_table" {
  vpc_id = local.client_vpc_id

  # RP route via TGW
  route {
    cidr_block         = var.rp_vpc_cidr
    transit_gateway_id = var.transit_gateway_id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = local.client_vpc_id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "route_table_assoc" {
  subnet_id      = var.client_subnet_id
  route_table_id = aws_route_table.route_table.id
}
