output "vpc_endpoint_sg_id" {
  description = "The id of the vpc endpoint sg"
  value       = aws_security_group.vpc_endpoint_sg.id
}

output "ec2_instance_ssm_access_instance_profile_name" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_instance_ssm_access_instance_profile.name
}