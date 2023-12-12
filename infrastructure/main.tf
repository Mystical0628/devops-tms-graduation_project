terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket         = "dos15-dubovets-gd-terraform-s3"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "dos15-dubovets-gd-terraform-lock"
    access_key     = "AKIAU4L6PJKVGIIMIY4P"
    secret_key     = "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"
  }
}

module "network" {
  source = "./modules/network"

  name = "dubovets-gp"

  vpc_cidr_block       = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  subnet_public_cidr_block  = var.subnet_public_cidr_block
  subnet_private_cidr_block = var.subnet_private_cidr_block
  subnet_availability_zone  = "us-east-1a"
}

module "security" {
  source = "./modules/security"

  name = "dubovets-gp"

  vpc_id = module.network.vpc_id
}

resource "aws_instance" "dubovets-gp-ec2-public-jenkins" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.instance_key_name

  subnet_id                   = module.network.sb_public_id
  vpc_security_group_ids      = [module.security.sg_id]
  associate_public_ip_address = true

  tags = {
    Name = "dubovets-gp-ec2"
  }
}

resource "aws_instance" "dubovets-gp-ec2-public-nginx" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.instance_key_name

  subnet_id                   = module.network.sb_public_id
  vpc_security_group_ids      = [module.security.sg_id]
  associate_public_ip_address = true

  tags = {
    Name = "dubovets-gp-ec2"
  }
}