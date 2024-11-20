# Create security group for AWS Elastic Load Balancer
resource "aws_security_group" "sg_elb" {
  name        = "elb_sg"
  description = "Allow HTTP traffic to the Load Balancer"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ var.WAN_CIDR ]
  }

  ingress { # ICMP: 0='echo reply', 8='echo request', -1=unlimited
    from_port       = 0
    to_port         = 0
    protocol        = "icmp"
    security_groups = [ var.WAN_CIDR ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ var.WAN_CIDR ]
  }
}