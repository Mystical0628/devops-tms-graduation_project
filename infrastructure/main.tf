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
  vpc_security_group_ids      = [module.security.sg_public_id]
  associate_public_ip_address = true

  tags = {
    Name = "dubovets-gp-ec2-jenkins_agent"
  }
}

resource "aws_instance" "dubovets-gp-ec2-public-nginx" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.instance_key_name

  subnet_id                   = module.network.sb_public_id
  vpc_security_group_ids      = [module.security.sg_public_id]
  associate_public_ip_address = true

  tags = {
    Name = "dubovets-gp-ec2-nginx"
  }
}

resource "aws_instance" "dubovets-gp-ec2-private-app" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.instance_key_name

  subnet_id                   = module.network.sb_private_id
  vpc_security_group_ids      = [module.security.sg_app_id]
  associate_public_ip_address = false

  tags = {
    Name = "dubovets-gp-ec2-app"
  }
}