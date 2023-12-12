variable "name" {
  description = "Name"
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

variable "subnet_availability_zone" {
  description = "The AWS Subnet availability zone"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}