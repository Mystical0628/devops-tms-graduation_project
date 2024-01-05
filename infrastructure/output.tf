output "instance_ip-jenkins_agent" {
  value = aws_instance.dubovets-gp-ec2-public-jenkins.public_ip
}

output "instance_id-jenkins_agent" {
  value = aws_instance.dubovets-gp-ec2-public-jenkins.id
}

output "instance_ip-nginx" {
  value = aws_instance.dubovets-gp-ec2-public-nginx.public_ip
}

output "instance_id-nginx" {
  value = aws_instance.dubovets-gp-ec2-public-nginx.id
}

output "instance_ip-app" {
  value = aws_instance.dubovets-gp-ec2-public-nginx.private_ip
}

output "instance_id-app" {
  value = aws_instance.dubovets-gp-ec2-public-nginx.id
}