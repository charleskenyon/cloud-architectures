output "app_us_east_1_asg_id" {
  description = "The id of the primary regions asg"
  value       = module.app_us_east_1.asg_id
}

output "app_eu_west_2_asg_id" {
  description = "The id of the secondary regions asg"
  value       = module.app_eu_west_2.asg_id
}

output "domain" {
  value = var.domain
}