# output "frontend_subnet_ID" {
#   description = "Frontend subnet ID, to be used for Auto Scaling Group of TomCat servers and a jump server."
#   value = aws_instance.bastion.subnet_id
# }

# output "backend_subnet_ID" {
#   description = "Backend subnet ID, to be used for MySQL DB server, MemcacheD and RabbitMQ servers."
#   value = aws_instance.backend.subnet_id
# }

output "app01_public_IP" {
  description = "value of the public IP address of the jump server"
  value = aws_instance.frontend.public_ip
}

# output "bastion_public_IP" {
#   description = "value of the public IP address of the jump server"
#   value = aws_instance.bastion.public_ip
# }

# output "bastion_private_IP" {
#   description = "value of the private IP address of the jump server"
#   value = aws_instance.bastion.private_ip
# }

# output "backend_private_IP" {
#   description = "value of the private IP address of the MySQL DB server"
#   value = aws_instance.backend.private_ip
# }

# output "memcache_private_IP" {
#   description = "value of the private IP address of the MemcacheD server"
#   value = aws_instance.memcache.private_ip
# }

# output "rabbitmq_private_IP" {
#   description = "value of the private IP address of the RabbitMQ server"
#   value = aws_instance.rabbitmq.private_ip
# }

# output "db_instance_ID" {
#   value = aws_instance.backend.id
# }

# output "bastion_instance_ID" {
#   value = aws_instance.backend.id
# }

output "ec2_instance_profile_arn" {
  value = module.instance_profile_setup.instance_profile_arn
}
