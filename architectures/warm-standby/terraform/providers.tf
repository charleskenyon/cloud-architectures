locals {
  default_tags = {
    Stack = var.arch
  }
}

provider "aws" {
  region              = "us-east-1"
  alias               = "us_east_1"
  allowed_account_ids = [var.deployment_account]

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  region = "eu-west-2"
  alias  = "eu_west_2"
  default_tags {
    tags = local.default_tags
  }
}
