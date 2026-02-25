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

variable "vpc1_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc2_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "customer_gateway_device_external_ip" {
  type    = string
  default = "86.28.225.233"
}

variable "customer_gateway_device_lan_cidr" {
  type    = string
  default = "192.168.0.0/24"
}

variable "customer_gateway_device_lan_ip" {
  type    = string
  default = "192.168.0.58"
}