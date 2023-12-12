variable "region" {
  description = "The AWS region"
  type        = string
}

variable "access_key" {
  description = "The AWS access key"
  type        = string
}

variable "secret_key" {
  description = "The AWS secret key"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The AWS VPC CIDR block"
  type        = string
}

variable "subnet_public_cidr_block" {
  description = "The AWS Subnet public CIDR block"
  type        = string
}

variable "subnet_private_cidr_block" {
  description = "The AWS Subnet private CIDR block"
  type        = string
}

variable "instance_ami" {
  description = "The AWS EC2 AMI"
  type        = string
}

variable "instance_type" {
  description = "The AWS EC2 type"
  type        = string
}

variable "instance_key_name" {
  description = "The AWS EC2 SSH Key name"
  type        = string
}