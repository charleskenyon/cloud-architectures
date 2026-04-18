variable "app_name" {
  description = "The name of the app"
  type        = string
}

variable "vpc_id" {
  description = "The VPC id"
  type        = string
}

variable "subnets" {
  description = "The subnets in which to deploy the app"
  type        = list(string)
}

variable "instance_profile_arn" {
  description = "The app instance profile arn"
  type        = string
}

variable "is_primary_region" {
  description = "Is this app in the primary or secondary failover region"
  type        = bool
}

variable "rds_endpoint" {
  description = "The RDS instance endpoint"
  type        = string
}