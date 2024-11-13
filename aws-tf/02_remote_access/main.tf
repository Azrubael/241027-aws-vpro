# Training configuration for running a bastion server and one backend server
# in order to practice the technology of establishing a ssh connection
# in AWS Cloud Environment

# Get the existed default AWS VPC ID by tag
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.VPC_NAME]
  }
}


# Get or create frontend subnet
data "aws_subnet" "frontend" {
  count = length(data.aws_vpc.selected.id) > 0 ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.FRONTEND_SUBNET_NAME]
  }
  vpc_id = data.aws_vpc.selected.id
}


resource "aws_subnet" "frontend" {
  count      = length(data.aws_subnet.frontend) == 0 ? 1 : 0
  vpc_id     = data.aws_vpc.selected.id
  cidr_block = var.FRONTEND_CIDR
  tags = {
    Name = var.FRONTEND_SUBNET_NAME
  }
}


# Get or create backend subnet
data "aws_subnet" "backend" {
  count = length(data.aws_vpc.selected.id) > 0 ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.BACKEND_SUBNET_NAME]
  }
  vpc_id = data.aws_vpc.selected.id
}


resource "aws_subnet" "backend" {
  count      = length(data.aws_subnet.backend) == 0 ? 1 : 0
  vpc_id     = data.aws_vpc.selected.id
  cidr_block = var.BACKEND_CIDR
  tags = {
    Name = var.BACKEND_SUBNET_NAME
  }
}


# Create security group for frontend
resource "aws_security_group" "front_sg" {
  name        = "front-sg"
  description = "Frontend security group for application and jump servers."
  vpc_id      = data.aws_vpc.selected.id

  dynamic "ingress" {
    for_each = var.FRONTEND_PORTS

    content {
      from_port   = ingress.value[1]
      to_port     = ingress.value[1]
      protocol    = ingress.value[0]
      cidr_blocks = [var.WAN_IP]
    }
  }
}


# Create security group for backend
resource "aws_security_group" "back_sg" {
  name        = "back-sg"
  description = "Backend security group for DB, MemcacheD and RabbitMQ servers."
  vpc_id      = data.aws_vpc.selected.id

  dynamic "ingress" {
    for_each = var.BACKEND_PORTS

    content {
      from_port   = ingress.value[1]
      to_port     = ingress.value[1]
      protocol    = ingress.value[0]
      cidr_blocks = [var.FRONTEND_CIDR]
    }
  }
}


# Getting the IDs of the created subnets
locals {
  # Assign subnet ID if it exists or returns the ID of the newly created subnet
  frontend_subnet_id = length(data.aws_subnet.frontend) > 0 ? data.aws_subnet.frontend[0].id : aws_subnet.frontend[0].id
  backend_subnet_id = length(data.aws_subnet.backend) > 0 ? data.aws_subnet.backend[0].id : aws_subnet.backend[0].id
}


# Run EC2 instance 'bastion'
resource "aws_instance" "bastion" {
  ami                         = var.OS_IMAGE_ID
  instance_type               = "t2.micro"
  key_name                    = "241107-key"
  subnet_id                   = local.frontend_subnet_id
  associate_public_ip_address = true
  private_ip                  = var.BASTION_IP
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Name = "jump01"
    Server = "Bastion"
  }
  user_data = templatefile("${path.module}/vm-template-scripts/jump-template-script.sh", {})
}

# Run EC2 instance 'TomCat'
resource "aws_instance" "frontend" {
  ami                         = var.OS_IMAGE_ID
  instance_type               = "t2.micro"
  key_name                    = "vpro-key"
  subnet_id                   = local.frontend_subnet_id
  associate_public_ip_address = true
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Name = "app01"
    Server = "TomCat"
  }
  user_data = templatefile("${path.module}/vm-template-scripts/tomcat-template-script.sh", {
    DATABASE_PASS = var.DB_PASS
  })
}

# Run EC2 instance 'MySQL'
resource "aws_instance" "backend" {
  ami                         = var.OS_IMAGE_ID
  instance_type               = "t2.micro"
  key_name                    = "vpro-key"
  subnet_id                   = local.backend_subnet_id
  associate_public_ip_address = false
  private_ip                  = var.DATABASE_IP
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Name = "db01"
    Server = "MySQL"
  }
  user_data = templatefile("${path.module}/vm-template-scripts/db-template-script.sh", {
    DATABASE_PASS = var.DB_PASS
  })
}


module "backend_nat" {
  source = "./backend_nat"
  wan = var.WAN_IP
  public_subnet_id = local.frontend_subnet_id
  private_subnet_id = local.backend_subnet_id
  vpc_net_id = data.aws_vpc.selected.id
  route_table_tag = "vpro_Backend_Route_Tabl"
}

