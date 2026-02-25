module "ssm_private_access" {
  source = "../../../common/terraform/modules/ssm-private-access"

  vpc_id    = aws_vpc.vpc1.id
  vpc_cidr  = var.vpc1_cidr
  region    = var.region
  arch      = var.arch
  subnet_id = aws_subnet.vpc1_private_subnet.id
}

# Route53 Resolver endpoint

resource "aws_route53_resolver_endpoint" "vpc1_inbound_resolver_endpoint" {
  name                   = "${var.arch}-inbound-resolver"
  direction              = "INBOUND"
  resolver_endpoint_type = "IPV4"

  security_group_ids = [
    aws_security_group.route53_endpoint_sg.id
  ]

  ip_address {
    subnet_id = aws_subnet.vpc1_private_subnet.id
    ip        = cidrhost(aws_subnet.vpc1_private_subnet.cidr_block, 20)
  }

  ip_address {
    subnet_id = aws_subnet.vpc1_private_subnet.id # simplified to one subnet, should be multiple for high availability
    ip        = cidrhost(aws_subnet.vpc1_private_subnet.cidr_block, 21)
  }

  protocols = ["Do53", "DoH"]
}

resource "aws_security_group" "route53_endpoint_sg" {
  name   = "${var.arch}-route53-endpoint-sg"
  vpc_id = aws_vpc.vpc1.id
}

resource "aws_vpc_security_group_ingress_rule" "route53_endpoint_sg_ingress_tcp" {
  security_group_id = aws_security_group.route53_endpoint_sg.id
  from_port         = 53
  to_port           = 53
  ip_protocol       = "tcp"
  cidr_ipv4         = var.customer_gateway_device_lan_cidr
}

resource "aws_vpc_security_group_ingress_rule" "route53_endpoint_sg_ingress_udp" {
  security_group_id = aws_security_group.route53_endpoint_sg.id
  from_port         = 53
  to_port           = 53
  ip_protocol       = "udp"
  cidr_ipv4         = var.customer_gateway_device_lan_cidr
}

resource "aws_vpc_security_group_egress_rule" "route53_endpoint_sg_egress_all" {
  security_group_id = aws_security_group.route53_endpoint_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}