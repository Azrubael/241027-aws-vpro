# Create a security group for a jump server
resource "aws_security_group" "sg_jump" {
  name        = "jump-sg"
  description = "Bastion security group."
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "Bastion Security Group"
  }

  ingress {
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks   = [ var.WAN_CIDR ]
  }

  ingress { # ICMP: 0='echo reply', 8='echo request', -1=unlimited
    from_port     = -1
    to_port       = -1
    protocol      = "icmp"
    cidr_blocks   = [ var.WAN_CIDR ]
  }

  egress {
    from_port     = -1
    to_port       = -1
    protocol      = "icmp"
    cidr_blocks   = [ var.WAN_CIDR ]
  }

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = [ var.WAN_CIDR ]
  }
}