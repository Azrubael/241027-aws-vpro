# Create security group for AWS Elastic Load Balancer
resource "aws_security_group" "sg_alb" {
  name        = "alb-sg"
  description = "Allow HTTP traffic to the Load Balancer"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "ALB Security Group"
  }

  dynamic "ingress" {
    for_each = var.LB_INGRESS
    content {
      from_port      = ingress.value[1]
      to_port        = ingress.value[1]
      protocol       = ingress.value[0]
      cidr_blocks    = [ var.WAN_CIDR ]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ var.WAN_CIDR ]
  }
}