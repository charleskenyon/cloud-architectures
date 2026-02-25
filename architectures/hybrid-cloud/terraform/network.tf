# VPC1

resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc1_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.arch}-vpc-1"
  }
}

resource "aws_subnet" "vpc1_private_subnet" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = cidrsubnet(var.vpc1_cidr, 8, 1)

  tags = {
    Name = "${var.arch}-vpc-1-private-subnet-1"
  }
}

resource "aws_route_table" "vpc1_route_table" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "${var.arch}-vpc-1-route-table"
  }
}

resource "aws_route_table_association" "vpc1_route_table_assoc" {
  subnet_id      = aws_subnet.vpc1_private_subnet.id
  route_table_id = aws_route_table.vpc1_route_table.id
}

# VPC2

resource "aws_vpc" "vpc2" {
  cidr_block           = var.vpc2_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.arch}-vpc-2"
  }
}

resource "aws_subnet" "vpc2_private_subnet" {
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = cidrsubnet(var.vpc2_cidr, 8, 1)


  tags = {
    Name = "${var.arch}-vpc-2-private-subnet-1"
  }
}

resource "aws_route_table" "vpc2_route_table" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "${var.arch}-vpc-2-route-table"
  }
}

resource "aws_route_table_association" "vpc2_route_table_assoc" {
  subnet_id      = aws_subnet.vpc2_private_subnet.id
  route_table_id = aws_route_table.vpc2_route_table.id
}

# Transit Gateway

resource "aws_ec2_transit_gateway" "tgw" {
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "${var.arch}-transit-gateway"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vp1_attachment" {
  subnet_ids         = [aws_subnet.vpc1_private_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.vpc1.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vp2_attachment" {
  subnet_ids         = [aws_subnet.vpc2_private_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.vpc2.id
}

resource "aws_route" "vpc1_tgw_route" {
  route_table_id         = aws_route_table.vpc1_route_table.id
  destination_cidr_block = var.vpc2_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc2_tgw_route" {
  route_table_id         = aws_route_table.vpc2_route_table.id
  destination_cidr_block = var.vpc1_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}