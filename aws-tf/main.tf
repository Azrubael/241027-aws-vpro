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
  count = length(data.aws_subnet.frontend) == 0 ? 1 : 0
  vpc_id     = data.aws_vpc.selected.id
  cidr_block = var.FRONTEND_CIDR
  tags = {
    Name = var.FRONTEND_SUBNET_NAME
  }
}

# Assign subnet ID to FRONT_ID
output "FRONT_ID" {
  value = length(data.aws_subnet.frontend) > 0 ? data.aws_subnet.frontend[0].id : aws_subnet.frontend[0].id
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
  count = length(data.aws_subnet.backend) == 0 ? 1 : 0
  vpc_id     = data.aws_vpc.selected.id
  cidr_block = var.BACKEND_CIDR
  tags = {
    Name = var.BACKEND_SUBNET_NAME
  }
}

# Assign subnet ID to BACK_ID
output "BACK_ID" {
  value = length(data.aws_subnet.backend) > 0 ? data.aws_subnet.backend[0].id : aws_subnet.backend[0].id
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

# Create bastion script
resource "local_file" "bastion_script" {
  content = <<-EOT
    #!/bin/bash
    useradd doorward
    usermod -aG sudo doorward
    mkdir -p /home/doorward/.ssh
    echo "${tls_private_key.doorward_key.public_key_openssh}" >> /home/doorward/.ssh/authorized_keys
    chmod 600 /home/doorward/.ssh/authorized_keys
    chown -R doorward:doorward /home/doorward/.ssh
  EOT
  filename = "${path.module}/bastion-script.sh"
}

# Create userdata script for backend
resource "local_file" "userdata_script" {
  content = <<-EOT
    #!/bin/bash
    useradd doorward
    usermod -aG sudo doorward
    mkdir -p /home/doorward/.ssh
    echo "${tls_private_key.doorward_key.public_key_openssh}" >> /home/doorward/.ssh/authorized_keys
    chmod 600 /home/doorward/.ssh/authorized_keys
    chown -R doorward:doorward /home/doorward/.ssh
  EOT
  filename = "${path.module}/userdata-script.sh"
}

# Run EC2 instance 'bastion'
resource "aws_instance" "bastion" {
  ami                    = var.OS_IMAGE_ID
  instance_type         = "t2.micro"
  key_name              = "vpro-key"
  subnet_id             = aws_subnet.frontend[0].id
  associate_public_ip_address = true
  private_ip            = var.BASTION_IP
  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Server = "Bastion"
  }

  user_data = file(local_file.bastion_script.filename)
}

# Run EC2 instance 'backend'
resource "aws_instance" "backend" {
  ami                    = var.OS_IMAGE_ID
  instance_type         = "t2.micro"
  key_name              = "vpro-key"
  subnet_id             = aws_subnet.backend[0].id
  associate_public_ip_address = false
  private_ip            = var.DATABASE_IP
  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Server = "Backend"
  }

  user_data = file(local_file.userdata_script.filename)
}

# Outputs
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "backend_private_ip" {
  value = aws_instance.backend.private_ip
}