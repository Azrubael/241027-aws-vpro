# Running a WEB application with a DB in a single subnet 
# in order to practice the technology of autoscaling
# in AWS Cloud Environment

# Get the existed default AWS VPC ID by tag
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [ var.VPC_NAME ]
  }
}


# Get or create sandbox subnet
data "aws_subnet" "sandbox" {
  # count = var.SANDBOX_CIDR == cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 2) ? 1 : 0
  count = length(data.aws_vpc.selected.id) > 0 && var.SANDBOX_CIDR == cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 2) ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.SANDBOX_SUBNET_NAME]
  }
  vpc_id = data.aws_vpc.selected.id
}

# Assign tag to the subnet if it doesn't exist
resource "aws_subnet" "sandbox" {
  count = length(data.aws_subnet.sandbox) == 0 ? 1 : 0
  vpc_id = data.aws_vpc.selected.id
  cidr_block = var.SANDBOX_CIDR
  tags = {
    Name = var.SANDBOX_SUBNET_NAME
  }
}

locals {
  # Assign subnet ID if it exists or the ID of the newly created one
  sandbox_subnet_id = length(data.aws_subnet.sandbox) > 0 ? data.aws_subnet.sandbox[0].id : aws_subnet.sandbox[0].id
}


# Create a security group for a jump server
resource "aws_security_group" "jump_sg" {
  name        = "jump-sg"
  description = "Bastion security group."
  vpc_id      = data.aws_vpc.selected.id

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


# Create a security group for frontend
resource "aws_security_group" "front_sg" {
  name        = "front-sg"
  description = "Frontend security group for application servers."
  vpc_id      = data.aws_vpc.selected.id

  dynamic "ingress" {
    for_each = var.FRONTEND_INGRESS
    content {
      from_port     = ingress.value[1]
      to_port       = ingress.value[1]
      protocol      = ingress.value[0]
      cidr_blocks   = [ var.WAN_CIDR ]
    }
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [ aws_security_group.jump_sg.id ]
  }

  ingress { # ICMP: 0='echo reply', 8='echo request', -1=unlimited
    from_port       = 0
    to_port         = 0
    protocol        = "icmp"
    security_groups = [ aws_security_group.jump_sg.id ]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = [
      var.WAN_CIDR,
      var.SANDBOX_CIDR
    ]
  }

}


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

  # egress {
  #   from_port       = 0
  #   to_port         = 0
  #   protocol        = "-1"
  #   cidr_blocks     = [
  #     var.WAN_CIDR,
  #     var.SANDBOX_CIDR
  #   ]
  # }

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


# Create IAM role and policy for EC2 instance
# and bind the policy to the role to allow access to S3 bucket
module "instance_profile_setup" {
  source = "./instance_profile_setup"
  s3_bucket = var.BUCKET_NAME
  bucket_role_name = var.BUCKET_ROLE_NAME
  bucket_policy_name = var.BUCKET_POLICY_NAME
  instance_profile_name = var.INSTANCE_PROFILE_NAME
}


# Run EC2 instance 'TomCat'
resource "aws_instance" "frontend" {
  ami                         = var.OS_IMAGE_ID
  instance_type               = "t2.micro"
  key_name                    = "vpro-key"
  subnet_id                   = local.sandbox_subnet_id
  security_groups = [ aws_security_group.front_sg.id ]
  associate_public_ip_address = true

  credit_specification {
    cpu_credits = "standard"
  }

  iam_instance_profile = module.instance_profile_setup.instance_profile_name

  tags = {
    Name = "app01"
    Server = "TomCat"
  }

  user_data = templatefile("${path.module}/vm-template-scripts/tomcat-template-script.sh", {
    db_ip = var.DATABASE_IP
    mc_ip = var.MEMCACHE_IP
    rmq_ip = var.RABBITMQ_IP
    S3_BUCKET_NAME = var.BUCKET_NAME
  })
  depends_on = [ aws_subnet.sandbox, aws_security_group.front_sg ]
}


# Run EC2 instance 'MySQL'
resource "aws_instance" "backend" {
  ami                         = var.OS_IMAGE_ID
  instance_type               = "t2.micro"
  key_name                    = "vpro-key"
  subnet_id                   = local.sandbox_subnet_id
  associate_public_ip_address = true  # ------ CHANGED! ------
  security_groups = [ aws_security_group.back_sg.id ]
  private_ip                  = var.DATABASE_IP

  credit_specification {
    cpu_credits = "standard"
  }

  iam_instance_profile = module.instance_profile_setup.instance_profile_name

  tags = {
    Name = "db01"
    Server = "MySQL"
  }

  user_data = templatefile("${path.module}/vm-template-scripts/db-template-script.sh", {
    DATABASE_PASS = var.DB_PASS
    S3_BUCKET_NAME = var.BUCKET_NAME
  })

}

/*
# Run EC2 instance 'memcache'
resource "aws_instance" "memcache" {
  ami                         = var.OS_IMAGE_ID
  instance_type               = "t2.micro"
  key_name                    = "vpro-key"
  subnet_id                   = local.sandbox_subnet_id
  associate_public_ip_address = false
  private_ip                  = var.MEMCACHE_IP
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Name = "mc01"
    Server = "MemcacheD"
  }
  user_data = templatefile("${path.module}/vm-template-scripts/mc-template-script.sh", {
    db_ip = var.DATABASE_IP
    mc_ip = var.MEMCACHE_IP
    rmq_ip = var.RABBITMQ_IP
  })
}

# Run EC2 instance 'rabbitmq' on  -= Amazon CentOS Stream 9 =-
resource "aws_instance" "rabbitmq" {
  ami                         = "ami-0df2a11dd1fe1f8e3"
  instance_type               = "t2.small"
  key_name                    = "vpro-key"
  subnet_id                   = local.sandbox_subnet_id
  associate_public_ip_address = false
  private_ip                  = var.RABBITMQ_IP
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Name = "rmq01"
    Server = "RabbitMQ"
  }
  user_data = templatefile("${path.module}/vm-template-scripts/rmq-template-script.sh", {
    db_ip = var.DATABASE_IP
    mc_ip = var.MEMCACHE_IP
    rmq_ip = var.RABBITMQ_IP
  })
}


*/
# Run EC2 instance 'bastion'
resource "aws_instance" "bastion" {
  ami                         = var.OS_IMAGE_ID
  instance_type               = "t2.micro"
  key_name                    = "241107-key"
  subnet_id                   = local.sandbox_subnet_id
  associate_public_ip_address = true
  private_ip                  = var.BASTION_IP

  security_groups = [ 
    aws_security_group.front_sg.id, 
    aws_security_group.jump_sg.id
  ]

  credit_specification {
    cpu_credits = "standard"
  }

  iam_instance_profile = module.instance_profile_setup.instance_profile_name
  tags = {
    Name = "jump01"
    Server = "Bastion"

  }
 
  user_data = templatefile("${path.module}/vm-template-scripts/jump-template-script.sh", {
    db_ip = var.DATABASE_IP
    mc_ip = var.MEMCACHE_IP
    rmq_ip = var.RABBITMQ_IP
    S3_BUCKET_NAME = var.BUCKET_NAME
  })
}

