variable "default_tags" {
  type        = map
  description = "A map of tags" 
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "ami" {
  type        = string
  description = "The description of the VM"
}

variable "subnet_ids" {
  type        = string
  description = "The list of subnet used by the instance"
}

variable "security_groups" {
  type        = list(string)
  description = "The list of security groups used by the instance"
}

variable "key_name" {
  type        = string
  description = "The key used to ssh into the instance"
}

variable "instance_name" {
  type        = string
  description = "The name of the instance"
}

variable "instance_profile" {
  type        = string
  description = "The name of the instance profile"
}

variable "user_data" {
  type        = string
  description = "User data to apply on instance"
  default     = ""
}
