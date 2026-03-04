output "function_arn" {
  description = "The ARN of the function"
  value       = aws_lambda_function.example_lambda.arn
}
