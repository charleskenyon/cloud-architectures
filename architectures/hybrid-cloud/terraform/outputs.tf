output "vpc1_ec2_instance_hostname" {
  description = "The private hostname of VPC1 test EC2 Instance"
  value       = aws_instance.vpc1_ec2_instance.private_dns
}

output "vpc1_ec2_instance_private_ip" {
  description = "The private ip of VPC1 test EC2 Instance"
  value       = aws_instance.vpc1_ec2_instance.private_ip
}

output "vpc2_ec2_instance_private_ip" {
  description = "The private ip of VPC2 test EC2 Instance"
  value       = aws_instance.vpc2_ec2_instance.private_ip
}

output "vpc1_ec2_instance_id" {
  description = "The instace id of VPC1 test EC2 Instance"
  value       = aws_instance.vpc1_ec2_instance.id
}

output "vpc2_ec2_instance_id" {
  description = "The instace id of VPC1 test EC2 Instance"
  value       = aws_instance.vpc2_ec2_instance.id
}

output "customer_gateway_device_lan_ip" {
  description = "The private ip or the Customer Gateway Device"
  value       = var.customer_gateway_device_lan_ip
}

output "vpc1_inbound_resolver_ip1" {
  value       = tolist(aws_route53_resolver_endpoint.vpc1_inbound_resolver_endpoint.ip_address)[0].ip
  description = "The first Route53 Resolver IP"
}

output "vpc1_inbound_resolver_ip2" {
  value       = tolist(aws_route53_resolver_endpoint.vpc1_inbound_resolver_endpoint.ip_address)[1].ip
  description = "The second Route53 Resolver IP"
}