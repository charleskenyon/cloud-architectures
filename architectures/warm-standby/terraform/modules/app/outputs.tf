output "alb_url" {
  description = "The load balancer url"
  value       = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  description = "The load balancer zone id"
  value       = aws_lb.alb.zone_id
}

output "instance_sg_id" {
  description = "The instance security group id"
  value       = aws_security_group.asg_instance_sg.id
}

output "asg_id" {
  description = "The id of the auto scaling group attached to ALB"
  value       = aws_autoscaling_group.asg.id
}

output "alb_arn_suffix" {
  description = "The ALB arn suffix for use with CloudWatch Metrics"
  value       = aws_lb.alb.arn_suffix
}

output "target_group_arn_suffix" {
  description = "The ALB target group arn suffix for use with CloudWatch Metrics"
  value       = aws_lb_target_group.alb_target_group.arn_suffix
}