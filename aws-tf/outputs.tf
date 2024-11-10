output "frontend_subnet_ID" {
  value = aws_instance.bastion.subnet_id
}

output "backend_subnet_ID" {
  value = aws_instance.backend.subnet_id
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