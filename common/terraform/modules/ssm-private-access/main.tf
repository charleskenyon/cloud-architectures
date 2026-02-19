locals {
  vpc_endpoints = [
    "com.amazonaws.us-east-1.ssm",
    "com.amazonaws.us-east-1.ec2messages",
    "com.amazonaws.us-east-1.ssmmessages"
  ]
}

resource "aws_vpc_endpoint" "vpc_endpoints" {
  for_each          = local.vpc_endpoints
  vpc_id            = var.vpc_id
  service_name      = each.value
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_endpoint_sg.id,
  ]

  private_dns_enabled = true
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "${var.arch}-sg-vpc-endpoint"
  description = "Allow HTTPS from VPC to VPC endpoints"
  vpc_id      = var.vpc_id

  ingress = {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    protocol    = "-1"
    cidr_blocks = "0.0.0.0"
  }
}