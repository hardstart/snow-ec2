output "instance_info" {
  value       = module.ec2
  description = "The instance info"
}

output "instance_ip" {
  value       = module.ec2.instance_ip
  description = "The instance ip"
}
