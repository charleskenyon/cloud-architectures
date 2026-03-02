locals {
  default_tags = {
    Stack = var.arch
  }
}

provider "aws" {
  region              = var.region
  allowed_account_ids = [var.deployment_account]

  default_tags {
    tags = local.default_tags
  }
}
