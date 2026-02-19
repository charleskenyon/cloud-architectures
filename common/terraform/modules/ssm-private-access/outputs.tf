output "vpc_endpoint_sg_id" {
  description = "The id of the vpc endpoint sg"
  value       = aws_security_group.vpc_endpoint_sg.id
}