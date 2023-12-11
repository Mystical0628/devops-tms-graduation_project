terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
}

module "network" {
    source = "./modules/network"

    name = "dubovets-gp"

    vpc_cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    enable_dns_support   = true

    subnet_cidr_block  = var.subnet_cidr_block
    subnet_availability_zone = "us-east-1a"
}

module "security" {
    source = "./modules/security"

    name = "dubovets-gp"

    vpc_id = module.network.vpc_id
}

resource "aws_instance" "dubovets-gp-ec2-public-jenkins" {
    ami = var.instance_ami
    instance_type = var.instance_type
    key_name = var.instance_key_name

    subnet_id = module.network.sb_public_id
    vpc_security_group_ids = [module.security.sg_id]
    associate_public_ip_address = true

    tags = {
        Name = "dubovets-gp-ec2"
    }
}

resource "aws_instance" "dubovets-gp-ec2-public-nginx" {
    ami = var.instance_ami
    instance_type = var.instance_type
    key_name = var.instance_key_name

    subnet_id = module.network.sb_public_id
    vpc_security_group_ids = [module.security.sg_id]
    associate_public_ip_address = true

    tags = {
        Name = "dubovets-gp-ec2"
    }
}