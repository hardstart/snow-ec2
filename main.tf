terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }
  }

  required_version = ">= 1.2.0"
}

locals {
  cost_center = lookup(var.cost_centers, var.cost_center)
  instance_fmt = lower(format("%s%s%s-%s%s",lower(substr(var.environment, 0, 1)),var.subnet_type == "DMZ" ? "e": "i","ae1", lower(local.cost_center.OU), var.instance_name))
  default_tags = {
    "Environment" = var.environment
    "Name" = ""
    "Service Role" = ""
  }
}

provider "aws" {
  default_tags {
    tags = merge(local.cost_center, local.default_tags)
  }
}

data "aws_ami" "ami" {
  most_recent = true
  owners = [lookup(var.ami_filters, var.os_platform).owner]

  filter {
    name   = "name"
    values = [lookup(var.ami_filters, var.os_platform).filter]
  }
}

resource "random_shuffle" "subnet" {
  input        = lookup(lookup(var.account_vars, var.environment),var.subnet_type).subnets
  result_count = 1
}

data "aws_instances" "instances" {
  instance_tags = {
    Name = "${local.instance_fmt}-*"
  }

  instance_state_names = ["running", "stopped"]
}

data "aws_instance" "instance" {
  for_each = toset(data.aws_instances.instances.ids)
  instance_id = each.key
}

resource "random_integer" "instance_id" {
  min = max(concat([0],[for i in data.aws_instance.instance: try(tonumber(regex("\\d*$",i.tags.Name)),0)])...) + 1
  max = max(concat([0],[for i in data.aws_instance.instance: try(tonumber(regex("\\d*$",i.tags.Name)),0)])...) + 1
  lifecycle {
    ignore_changes = [
      min,
      max,
    ]
  }
}

module "ec2" {
  source  = "app.terraform.io/healthfirst/EC2/aws"
  version = "1.7.0"
  ami                    = data.aws_ami.ami.id
  instance_type          = lookup(lookup(lookup(var.account_vars, var.environment).instance_sizes, var.os_platform == "RHEL8" ? "linux" : "windows"), lower(var.instance_size))
  subnet_ids             = element(random_shuffle.subnet.result,0)
  key_name               = lower(format("%s-%s-key", local.cost_center.OU, var.environment))
  user_data              = var.user_data
  instance_profile       = var.instance_profile
  security_groups        = [lookup(lookup(var.account_vars, var.environment),var.subnet_type).security_group]
  instance_name          = format("%s-%02s", local.instance_fmt, random_integer.instance_id.result)
}

#module "bluecat" {
#  source  = "app.terraform.io/healthfirst/bluecat/cln"
#  version = "1.13.0"
#  hostname = var.instance_name
#  password = var.bc_password
#  value    = module.ec2.instance_ip
#}
