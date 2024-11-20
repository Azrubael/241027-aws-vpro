output "app01_public_IP" {
  description = "value of the public IP address of the jump server"
  value = aws_instance.frontend.public_ip
}

output "bastion_public_IP" {
  description = "value of the public IP address of the jump server"
  value = aws_instance.bastion.public_ip
}

# output "db_private_IP" {
#    description = "value of the private IP address of the MySQL DB server"
#    value = aws_instance.backend.private_ip
# }

# output "memcache_private_IP" {
#   description = "value of the private IP address of the MemcacheD server"
#   value = aws_instance.memcache.private_ip
# }

# output "rabbitmq_private_IP" {
#   description = "value of the private IP address of the RabbitMQ server"
#   value = aws_instance.rabbitmq.private_ip
# }

output "ec2_instance_profile_arn" {
  value = module.instance_profile_setup.instance_profile_arn
}

output "sandbox_subnet_id" {
  value = local.sandbox_subnet_id
}

output "frontend_sg_id" {
  value = aws_security_group.front_sg.id
}

output "backend_sg_id" {
  value = aws_security_group.back_sg.id
}

# output "cdr_calc" {
#   value = cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 0)
# }
