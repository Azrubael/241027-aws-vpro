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

# Generate SSH key pair
resource "tls_private_key" "doorward_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create bastion script by calling the user_setup module for the bastion server setup
module "bastion_setup" {
  source     = "./user_setup"
  username   = "doorward"
  public_key = tls_private_key.doorward_key.public_key_openssh
  script_file = "bastion-setup-script.sh"
}

# Create userdata script for backend by calling the user_setup module for the backend server setup
module "backend_setup" {
  source     = "./user_setup"
  username   = "doorward"
  public_key = tls_private_key.doorward_key.public_key_openssh
  script_file = "db-setup-script.sh"
}

# Run EC2 instance 'bastion'
resource "aws_instance" "bastion" {
  ami                         = var.OS_IMAGE_ID
  instance_type               = "t2.micro"
  key_name                    = "vpro-key"
  # Assign subnet ID to if it exists or returns the ID of the newly created subnet
  subnet_id                   = length(data.aws_subnet.frontend) > 0 ? data.aws_subnet.frontend[0].id : aws_subnet.frontend[0].id
  associate_public_ip_address = true
  private_ip                  = var.BASTION_IP
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Server = "Bastion"
  }
  user_data = file(module.bastion_setup.script_file_path)
}

# Run EC2 instance 'backend'
resource "aws_instance" "backend" {
  ami                         = var.OS_IMAGE_ID
  instance_type               = "t2.micro"
  key_name                    = "vpro-key"
  # Assign subnet ID to if it exists or returns the ID of the newly created subnet
  subnet_id                   = length(data.aws_subnet.backend) > 0 ? data.aws_subnet.backend[0].id : aws_subnet.backend[0].id
  associate_public_ip_address = false
  private_ip                  = var.DATABASE_IP
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Server = "Backend"
  }
  user_data = file(module.backend_setup.script_file_path)
}
