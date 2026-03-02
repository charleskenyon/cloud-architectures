variable "region" {
  description = "The AWS region"
  type        = string
}

variable "arch" {
  description = "The name of the architecure"
  type        = string
}

variable "deployment_account" {
  description = "The AWS account to deploy the architecure"
  type        = string
}