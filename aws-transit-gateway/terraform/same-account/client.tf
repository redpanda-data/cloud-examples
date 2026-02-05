
locals {
  vm_user_data_with_cloud_config_directive = "#cloud-config\n${jsonencode(local.vm_user_data)}"

  client_vpc_cidr_block    = "10.10.0.0/16"
  client_subnet_cidr_block = "10.10.1.0/24"

  client_subnet_id = var.client_subnet_id == "" ? aws_subnet.client[0].id : var.client_subnet_id
  client_vpc_id    = var.client_subnet_id == "" ? aws_vpc.client[0].id : data.aws_subnet.client.vpc_id
}

resource "aws_vpc" "client" {
  count                = var.client_subnet_id == "" ? 1 : 0
  cidr_block           = local.client_vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "client" {
  count      = var.client_subnet_id == "" ? 1 : 0
  vpc_id     = aws_vpc.client[0].id
  cidr_block = local.client_subnet_cidr_block
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.default.id
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
  count         = var.deploy_test_client ? 1 : 0
  ami           = random_id.suffix.keepers.ami_id
  instance_type = "t3.nano"

  subnet_id = local.client_subnet_id
  key_name  = aws_key_pair.generated_key.key_name

  user_data_base64 = base64encode(local.vm_user_data_with_cloud_config_directive)
}

resource "aws_eip" "test_instance_eip" {
  count    = var.deploy_test_client ? 1 : 0
  instance = aws_instance.kafka_test[0].id
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = local.client_vpc_id
}

# It is slow to create a TGW, so we need to wait for it to be created before creating the route table
resource "time_sleep" "wait_60_seconds" {
  depends_on = [aws_ec2_transit_gateway.test]

  create_duration = "60s"
}

resource "aws_route_table" "route_table" {
  vpc_id = local.client_vpc_id

  # RP route via TGW
  route {
    cidr_block         = data.aws_vpc.rp_vpc.cidr_block
    transit_gateway_id = local.transit_gateway_id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  depends_on = [time_sleep.wait_60_seconds]
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = local.client_vpc_id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "route_table_assoc" {
  subnet_id      = local.client_subnet_id
  route_table_id = aws_route_table.route_table.id
}
