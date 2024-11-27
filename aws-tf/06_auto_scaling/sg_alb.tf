# Create security group for AWS Elastic Load Balancer
resource "aws_security_group" "sg_alb" {
  name        = "alb-sg"
  description = "Allow HTTP traffic to the Load Balancer"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "ALB Security Group"
  }

}


resource "aws_security_group_rule" "alb_ingress_wan" {
  count = length(var.LB_INGRESS)

  type              = "ingress"
  from_port         = var.LB_INGRESS[count.index][1]
  to_port           = var.LB_INGRESS[count.index][1]
  protocol          = var.LB_INGRESS[count.index][0]
  cidr_blocks       = [ var.WAN_CIDR ]
  security_group_id = aws_security_group.sg_alb.id
}


resource "aws_security_group_rule" "egress_alb_to_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [ var.WAN_CIDR ]
  security_group_id = aws_security_group.sg_alb.id
}