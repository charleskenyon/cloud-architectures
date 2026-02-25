locals {
  vpc_endpoints = [
    "com.amazonaws.${var.region}.ssm",
    "com.amazonaws.${var.region}.ec2messages",
    "com.amazonaws.${var.region}.ssmmessages"
  ]
}

resource "aws_vpc_endpoint" "vpc_endpoints" {
  for_each            = toset(local.vpc_endpoints)
  vpc_id              = var.vpc_id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id, ]
  private_dns_enabled = true
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "${var.arch}-sg-vpc-endpoint"
  description = "Allow HTTPS from VPC to VPC endpoints"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_sg_ingress_https" {
  security_group_id = aws_security_group.vpc_endpoint_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.vpc_endpoint_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# EC2 Instance Role for SSM

resource "aws_iam_role" "ec2_instance_ssm_access_role" {
  name = "${var.arch}-ec2-instance-ssm-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "Ec2AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_instance_ssm_access_role_ssm_policy" {
  role       = aws_iam_role.ec2_instance_ssm_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_instance_profile" "ec2_instance_ssm_access_instance_profile" {
  name = "${var.arch}-ec2-instance-ssm-access-role"
  role = aws_iam_role.ec2_instance_ssm_access_role.name
}