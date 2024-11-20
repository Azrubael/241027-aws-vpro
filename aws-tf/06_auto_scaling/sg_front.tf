# Create a security group for frontend
resource "aws_security_group" "sg_front" {
  name        = "front-sg"
  description = "Frontend security group for application servers."
  vpc_id      = data.aws_vpc.selected.id

  dynamic "ingress" {
    for_each = var.FRONTEND_INGRESS
    content {
      from_port     = ingress.value[1]
      to_port       = ingress.value[1]
      protocol      = ingress.value[0]
      cidr_blocks   = [ var.WAN_CIDR ]
    }
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [ aws_security_group.sg_jump.id ]
  }

  ingress { # ICMP: 0='echo reply', 8='echo request', -1=unlimited
    from_port       = 0
    to_port         = 0
    protocol        = "icmp"
    security_groups = [ aws_security_group.sg_jump.id ]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = [
      var.WAN_CIDR,
      var.SANDBOX_CIDR
    ]
  }

}