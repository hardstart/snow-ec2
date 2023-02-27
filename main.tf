terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  default_tags {
    tags = var.default_tags
  }
}

locals {
  instance_name = lower(format("%s%s%s-%s",lower(substr(var.environment, 0, 1)),var.subnet_type == "DMZ" ? "e": "i","ae1", var.instance_name))
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
  input        = lookup(lookup(var.account_vars, var.environment),var.subnet_type)
  result_count = 1
}

data "aws_instances" "instances" {
  instance_tags = {
    Name = "${local.instance_name}-*"
  }

  instance_state_names = ["running", "stopped"]
}

resource "random_integer" "id" {
  min = length(data.aws_instances.instances.ids) + 1
  max = length(data.aws_instances.instances.ids) + 1
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
  instance_type          = var.instance_type
  subnet_ids             = element(random_shuffle.subnet.result,0)
  #key_name               = lower(format("%s-%s-key", lookup(var.cost_centers, var.cost_center).OU, var.environment))
  key_name               = "DevopsTestKey"
  user_data              = var.user_data
  instance_profile       = var.instance_profile
  security_groups        = var.security_groups
  instance_name          = format("%s-%02s", local.instance_name, random_integer.id.result)
}

#module "bluecat" {
#  source  = "app.terraform.io/healthfirst/bluecat/cln"
#  version = "1.13.0"
#  hostname = var.instance_name
#  password = var.bc_password
#  value    = module.ec2.instance_ip
#}
