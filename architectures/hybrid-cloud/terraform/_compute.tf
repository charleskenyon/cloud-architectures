# VPC1 test EC2 Instance

resource "aws_instance" "vpc1_ec2_instance" {
  ami                  = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type        = "t2.micro"
  iam_instance_profile = module.ssm_private_access.ec2_instance_ssm_access_instance_profile_name
  subnet_id            = aws_subnet.vpc1_private_subnet.id
  security_groups      = [aws_security_group.vpc1_ec2_instance_sg.id]

  tags = {
    Name = "${var.arch}-test-instance-1"
  }
}

resource "aws_security_group" "vpc1_ec2_instance_sg" {
  description = "SG to test ping VPC1 to VPC2 and VPN with SSM access"
  vpc_id      = aws_vpc.vpc1.id
}

resource "aws_vpc_security_group_egress_rule" "vpc1_ec2_instance_sg_egress_icmp_vpn" {
  security_group_id = aws_security_group.vpc1_ec2_instance_sg.id
  from_port         = 8
  to_port           = -1
  ip_protocol       = "icmp"
  cidr_ipv4         = var.customer_gateway_device_lan_cidr
}

resource "aws_vpc_security_group_egress_rule" "vpc1_ec2_instance_sg_egress_icmp_vpc2" {
  security_group_id = aws_security_group.vpc1_ec2_instance_sg.id
  from_port         = 8
  to_port           = -1
  ip_protocol       = "icmp"
  cidr_ipv4         = var.vpc2_cidr
}

resource "aws_vpc_security_group_egress_rule" "vpc1_ec2_instance_sg_egress_ssm_endpoint" {
  security_group_id            = aws_security_group.vpc1_ec2_instance_sg.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.ssm_private_access.vpc_endpoint_sg_id
}

# VPC2 test EC2 Instance

resource "aws_instance" "vpc2_ec2_instance" {
  ami             = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.vpc2_private_subnet.id
  security_groups = [aws_security_group.vpc2_ec2_instance_sg.id]
  tags = {
    Name = "${var.arch}-test-instance-2"
  }
}

resource "aws_security_group" "vpc2_ec2_instance_sg" {
  description = "SG to test ping VPC2 from VPC1"
  vpc_id      = aws_vpc.vpc2.id
}

resource "aws_vpc_security_group_ingress_rule" "vpc1_ec2_instance_sg_ingress_icmp_vpc2" {
  security_group_id = aws_security_group.vpc2_ec2_instance_sg.id
  from_port         = 8
  to_port           = -1
  ip_protocol       = "icmp"
  cidr_ipv4         = var.vpc1_cidr
}
