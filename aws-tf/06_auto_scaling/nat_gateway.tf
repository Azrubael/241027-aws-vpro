# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}


# Create a NAT Gateway in one of the public subnets
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = local.sandbox_subnet_id

  tags = {
    Name = "vpro-NAT-Gateway"
  }
}


# Create a private route table
resource "aws_route_table" "sandbox" {
  vpc_id = data.aws_vpc.selected.id

  route {
    cidr_block     = var.WAN_CIDR
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}


# Create an association of the route table with the private subnet
resource "aws_route_table_association" "sandbox32" {
  subnet_id      = local.sandbox_subnet_id
  route_table_id = aws_route_table.sandbox.id
}
resource "aws_route_table_association" "sandbox16" {
  subnet_id      = local.sandbox_subnet16_id
  route_table_id = aws_route_table.sandbox.id
}
