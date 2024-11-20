output "alb_public_IP" {
  description = "value of the public IP address of the application load balancer"
  value = aws_alb.front_end.dns_name
}

output "bastion_public_IP" {
  description = "value of the public IP address of the jump server"
  value = aws_instance.bastion.public_ip
}

# output "db_private_IP" {
#    description = "value of the private IP address of the MySQL DB server"
#    value = aws_instance.backend.private_ip
# }

output "ec2_instance_profile_arn" {
  value = module.instance_profile_setup.instance_profile_arn
}

output "sandbox_subnet_id" {
  value = local.sandbox_subnet_id
}

output "sg_frontend_id" {
  value = aws_security_group.sg_front.id
}

output "sg_backend_id" {
  value = aws_security_group.sg_back.id
}

output "sg_aws_elb_id" {
  value = aws_security_group.sg_alb.id
}