output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "sb_public_id" {
  value       = aws_subnet.public.id
  description = "The ID of the subnet"
}

output "sb_private_id" {
  value       = aws_subnet.private.id
  description = "The ID of the subnet"
}

output "rt_id" {
  value       = aws_route_table.main.id
  description = "The ID of the route table"
}

output "igw_id" {
  value       = aws_internet_gateway.main.id
  description = "The ID of the internet gateway"
}
