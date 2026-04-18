data "aws_availability_zones" "available_us_east_1" {
  provider = aws.us_east_1
}

data "aws_availability_zones" "available_eu_west_2" {
  provider = aws.eu_west_2
}

locals {
  cidr_block_vpc1 = "10.0.0.0/16"
  cidr_block_vpc2 = "10.1.0.0/16"
}

# VPC us-east-1

resource "aws_vpc" "vpc_us_east_1" {
  provider             = aws.us_east_1
  cidr_block           = local.cidr_block_vpc1
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.arch}-vpc-us-east-1"
  }
}

resource "aws_subnet" "vpc_us_east_1_public_subnets" {
  count                   = length(data.aws_availability_zones.available_us_east_1.names)
  provider                = aws.us_east_1
  vpc_id                  = aws_vpc.vpc_us_east_1.id
  cidr_block              = cidrsubnet(local.cidr_block_vpc1, 8, count.index + 1)
  availability_zone       = data.aws_availability_zones.available_us_east_1.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.arch}-vpc-us-east-1-public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "vpc_us_east_1_igw" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.vpc_us_east_1.id

  tags = {
    Name = "${var.arch}-vpc-us-east-1-igw"
  }
}

resource "aws_route" "vpc_us_east_1_igw_route" {
  provider               = aws.us_east_1
  route_table_id         = aws_vpc.vpc_us_east_1.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc_us_east_1_igw.id
}

# VPC eu-west-2

resource "aws_vpc" "vpc_eu_west_2" {
  provider             = aws.eu_west_2
  cidr_block           = local.cidr_block_vpc2
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.arch}-vpc-eu-west-2"
  }
}

resource "aws_subnet" "vpc_eu_west_2_public_subnets" {
  count                   = length(data.aws_availability_zones.available_eu_west_2.names)
  provider                = aws.eu_west_2
  vpc_id                  = aws_vpc.vpc_eu_west_2.id
  cidr_block              = cidrsubnet(local.cidr_block_vpc2, 8, count.index + 1)
  availability_zone       = data.aws_availability_zones.available_eu_west_2.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.arch}-vpc-eu-west-2-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "vpc_eu_west_2_route_table" {
  provider = aws.eu_west_2
  vpc_id   = aws_vpc.vpc_eu_west_2.id

  tags = {
    Name = "${var.arch}-vpc-eu-west-2-route-table"
  }
}

resource "aws_internet_gateway" "vpc_eu_west_2_igw" {
  provider = aws.eu_west_2
  vpc_id   = aws_vpc.vpc_eu_west_2.id

  tags = {
    Name = "${var.arch}-vpc-eu-west-2-igw"
  }
}

resource "aws_route" "vpc_eu_west_2_igw_route" {
  provider               = aws.eu_west_2
  route_table_id         = aws_vpc.vpc_eu_west_2.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc_eu_west_2_igw.id
}
