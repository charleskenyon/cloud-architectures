module "ssm_private_access" {
  source = "../../../common/terraform/modules/ssm-private-access"

  vpc_id   = aws_vpc.vpc1.id
  vpc_cidr = var.vpc1_cidr
  region   = var.region
  arch     = var.arch
}