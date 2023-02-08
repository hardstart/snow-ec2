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
  version = "1.4.0"
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids
  key_name               = var.key_name
  user_data              = var.user_data
  iam_instance_profile   = var.instance_profile
  vpc_security_group_ids = var.security_groups
  instance_name          = var.instance_name
}
