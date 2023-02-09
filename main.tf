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

module "ec2" {
  source  = "app.terraform.io/healthfirst/EC2/aws"
  version = "1.5.0"
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_ids             = var.subnet_ids
  key_name               = var.key_name
  user_data              = var.user_data
  instance_profile       = var.instance_profile
  security_groups        = var.security_groups
  instance_name          = var.instance_name
}

module "bluecat" {
  source  = "app.terraform.io/healthfirst/bluecat/cln"
  version = "1.1.0"
  hostname = var.instance_name
  password = var.bc_password
  value    = module.ec2.instance_ip
}
