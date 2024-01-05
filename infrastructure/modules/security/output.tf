output "sg_public_id" {
  value       = aws_security_group.public.id
  description = "The ID of the Public Security group"
}

output "sg_app_id" {
  value       = aws_security_group.app.id
  description = "The ID of the App Security group"
}