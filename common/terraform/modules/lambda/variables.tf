variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "function_image" {
  description = "The image to use for the lambda container"
  type        = string
}

variable "handler" {
  description = "Handler for the Lambda function"
  type        = string
  default     = "index.handler"
}

variable "timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 128
}
