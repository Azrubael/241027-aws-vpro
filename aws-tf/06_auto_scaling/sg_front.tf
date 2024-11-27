# Create a security group for frontend
resource "aws_security_group" "sg_front" {
  name        = "front-sg"
  description = "Frontend security group for application servers."
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "TomCat Frontend Security Group"
  }

  # dynamic "ingress" {
  #   for_each = var.FRONTEND_INGRESS
  #   content {
  #     from_port      = ingress.value[1]
  #     to_port        = ingress.value[1]
  #     protocol       = ingress.value[0]
  #     security_groups = [ 
  #       aws_security_group.sg_alb.id,
  #       aws_security_group.sg_jump.id
  #     ]
  #   }
  # }

}


resource "aws_security_group_rule" "frontend_ingress_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = aws_security_group.sg_alb.id
  security_group_id = aws_security_group.sg_front.id
}


resource "aws_security_group_rule" "frontend_ingress_bastion" {
  count = length(var.FRONTEND_INGRESS)

  type              = "ingress"
  from_port         = var.FRONTEND_INGRESS[count.index][1]
  to_port           = var.FRONTEND_INGRESS[count.index][1]
  protocol          = var.FRONTEND_INGRESS[count.index][0]
  security_group_id = aws_security_group.sg_front.id

  source_security_group_id   = aws_security_group.sg_jump.id
}

# ICMP: 0='echo reply', 8='echo request', -1=unlimited
resource "aws_security_group_rule" "ingress_icmp_to_front" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "icmp"
  source_security_group_id = aws_security_group.sg_jump.id
  security_group_id = aws_security_group.sg_front.id
}


resource "aws_security_group_rule" "ingress_ssh_to_front" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = aws_security_group.sg_jump.id
  security_group_id = aws_security_group.sg_front.id
}


resource "aws_security_group_rule" "egress_front_to_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [
    var.WAN_CIDR,
    var.SANDBOX_CIDR
  ]
  security_group_id = aws_security_group.sg_front.id
}