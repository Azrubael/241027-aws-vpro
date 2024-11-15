variable "wan" {
  description = "CIDR the world outside"
  type = string
}
variable "public_subnet_id" {
  type = string
}
variable "private_subnet_id" {
  type = string
}
variable "vpc_net_id" {
  description = "VPC network ID"
  type = string
}
variable "route_table_tag" {
  type = string
}


# Create Elastic IP for NAT gateway
resource "aws_eip" "nat_eip" {
}


# Create NAT Gateway in the public subnet 'frontend'
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id    = var.public_subnet_id
}


# Create route table for the private subnet 'backend'
resource "aws_route_table" "backend_route_table" {
  vpc_id = var.vpc_net_id
  route {
    cidr_block = var.wan
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = var.route_table_tag
  }
}


# Route table association with the private subnet 'backend'
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "backend_association" {
  subnet_id      = var.private_subnet_id
  route_table_id = aws_route_table.backend_route_table.id
}
