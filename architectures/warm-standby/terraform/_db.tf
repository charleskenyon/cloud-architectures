// DB Primary Instance

resource "aws_db_subnet_group" "db_primary_subnet_group" {
  provider   = aws.us_east_1
  name       = "${var.arch}-primary-db-subnet-group"
  subnet_ids = [for v in aws_subnet.vpc_us_east_1_public_subnets : v.id]
}

resource "aws_security_group" "db_primary_sg" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.vpc_us_east_1.id
}

resource "aws_vpc_security_group_ingress_rule" "db_primary_sg_ingress" {
  provider                     = aws.us_east_1
  security_group_id            = aws_security_group.db_primary_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.app_us_east_1.instance_sg_id // lock incoming requests down to app instances
}

resource "aws_db_instance" "db_primary" {
  provider = aws.us_east_1

  allocated_storage = 10
  db_name           = replace("${var.arch}db", "-", "") # db name can only contain alphanumeric characters
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"

  username = "test_user"
  password = "test_password"

  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  backup_retention_period = 1

  db_subnet_group_name   = aws_db_subnet_group.db_primary_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_primary_sg.id]
}

// Cross-Regional DB Read Replica

resource "aws_db_subnet_group" "db_secondary_subnet_group" {
  provider   = aws.eu_west_2
  name       = "${var.arch}-secondary-db-subnet-group"
  subnet_ids = [for v in aws_subnet.vpc_eu_west_2_public_subnets : v.id]
}

resource "aws_security_group" "db_secondary_sg" {
  provider = aws.eu_west_2
  vpc_id   = aws_vpc.vpc_eu_west_2.id
}

resource "aws_vpc_security_group_ingress_rule" "db_secondary_sg_ingress" {
  provider = aws.eu_west_2

  security_group_id            = aws_security_group.db_secondary_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.app_eu_west_2.instance_sg_id // lock incoming requests down to app instances
}

resource "aws_db_instance" "db_secondary" {
  provider = aws.eu_west_2

  replicate_source_db = aws_db_instance.db_primary.arn

  instance_class          = "db.t3.micro"
  skip_final_snapshot     = true
  backup_retention_period = 1

  db_subnet_group_name   = aws_db_subnet_group.db_secondary_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_secondary_sg.id]
}