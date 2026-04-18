module "app_us_east_1" {
  source = "./modules/app"

  app_name             = "${var.arch}-us-east-1"
  vpc_id               = aws_vpc.vpc_us_east_1.id
  subnets              = [for v in aws_subnet.vpc_us_east_1_public_subnets : v.id]
  instance_profile_arn = aws_iam_instance_profile.app_instance_role_instance_profile.arn
  is_primary_region    = true
  rds_endpoint         = aws_db_instance.db_primary.address

  providers = {
    aws = aws.us_east_1
  }
}

module "app_eu_west_2" {
  source = "./modules/app"

  app_name             = "${var.arch}-eu-west-2"
  vpc_id               = aws_vpc.vpc_eu_west_2.id
  subnets              = [for v in aws_subnet.vpc_eu_west_2_public_subnets : v.id]
  instance_profile_arn = aws_iam_instance_profile.app_instance_role_instance_profile.arn
  is_primary_region    = false
  rds_endpoint         = aws_db_instance.db_secondary.address

  providers = {
    aws = aws.eu_west_2
  }

  depends_on = [module.app_us_east_1]
}

resource "aws_route53_zone" "public_hosted_zone" {
  name = var.domain
}

resource "aws_route53_health_check" "primary_health_check" {
  fqdn              = module.app_us_east_1.alb_url
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 10
}

resource "aws_route53_record" "app_us_east_1_alb_record" {
  zone_id        = aws_route53_zone.public_hosted_zone.zone_id
  name           = var.domain
  type           = "A"
  set_identifier = "primary"

  failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = aws_route53_health_check.primary_health_check.id

  alias {
    name                   = module.app_us_east_1.alb_url
    zone_id                = module.app_us_east_1.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app_eu_west_2_alb_record" {
  zone_id        = aws_route53_zone.public_hosted_zone.zone_id
  name           = var.domain
  type           = "A"
  set_identifier = "secondary"

  failover_routing_policy {
    type = "SECONDARY"
  }

  alias {
    name                   = module.app_eu_west_2.alb_url
    zone_id                = module.app_eu_west_2.alb_zone_id
    evaluate_target_health = true
  }
}