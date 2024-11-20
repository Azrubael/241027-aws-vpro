# Create security group for backend
resource "aws_security_group" "back_sg" {
  name        = "back-sg"
  description = "Backend security group for DB, MemcacheD and RabbitMQ servers."
  vpc_id      = data.aws_vpc.selected.id

  dynamic "ingress" {
    for_each = var.BACKEND_INGRESS
    content {
      from_port       = ingress.value[1]
      to_port         = ingress.value[1]
      protocol        = ingress.value[0]
      security_groups = [
        aws_security_group.front_sg.id,
        aws_security_group.jump_sg.id
      ]
    }
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self = true
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "icmp"
    security_groups = [ aws_security_group.jump_sg.id ]
  }

  dynamic "egress" {
    for_each = var.BACKEND_EGRESS
    content {
      from_port     = egress.value[1]
      to_port       = egress.value[1]
      protocol      = egress.value[0]
      cidr_blocks     = [
        var.WAN_CIDR,
        var.SANDBOX_CIDR
      ]   
    }
  }

}