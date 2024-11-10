# Assign subnet ID to FRONT_ID if it exists or returns the ID of the newly created subnet
output "frontend_subnet_ID" {
  value = length(data.aws_subnet.frontend) > 0 ? data.aws_subnet.frontend[0].id : aws_subnet.frontend[0].id
}

# Assign subnet ID to BACK_ID if it exists or returns the ID of the newly created subnet
output "backend_subnet_ID" {
  value = length(data.aws_subnet.backend) > 0 ? data.aws_subnet.backend[0].id : aws_subnet.backend[0].id
}

output "bastion_public_IP" {
  value = aws_instance.bastion.public_ip
}

output "bastion_private_IP" {
  value = aws_instance.bastion.private_ip
}

output "backend_private_IP" {
  value = aws_instance.backend.private_ip
}