variable "region" {
  description = "The AWS region"
  type        = string
}

variable "arch" {
  description = "The name of the architecure"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "The subnet in which to place the VPC Endpoint"
  type        = string
}