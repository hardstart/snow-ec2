output "instance_info" {
  value       = module.ec2.instance
  description = "The instance info"
}

output "instance_id" {
  value       = module.ec2.instance.id
  description = "The instance id"
}

