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


# Get or create the first sandbox subnet
data "aws_subnet" "sandbox" {
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


# Get or create the second sandbox subnet
data "aws_subnet" "sandbox16" {
  count = length(data.aws_vpc.selected.id) > 0 && var.SANDBOX_16_CIDR == cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 2) ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.SANDBOX_16_SUBNET_NAME]
  }
  vpc_id = data.aws_vpc.selected.id
}

# Assign tag to the subnet if it doesn't exist
resource "aws_subnet" "sandbox16" {
  count = length(data.aws_subnet.sandbox16) == 0 ? 1 : 0
  vpc_id = data.aws_vpc.selected.id
  cidr_block = var.SANDBOX_16_CIDR
  tags = {
    Name = var.SANDBOX_16_SUBNET_NAME
  }
}


locals {
  # Assign subnet ID if it exists or the ID of the newly created one
  sandbox_subnet_id = length(data.aws_subnet.sandbox) > 0 ? data.aws_subnet.sandbox[0].id : aws_subnet.sandbox[0].id
  sandbox_subnet16_id = length(data.aws_subnet.sandbox16) > 0 ? data.aws_subnet.sandbox16[0].id : aws_subnet.sandbox16[0].id
}


# Create IAM role and policy for EC2 instance
# and bind the policy to the role to allow access to S3 bucket
module "instance_profile_setup" {
  source                = "./instance_profile_setup"
  s3_bucket             = var.BUCKET_NAME
  bucket_role_name      = var.BUCKET_ROLE_NAME
  bucket_policy_name    = var.BUCKET_POLICY_NAME
  instance_profile_name = var.INSTANCE_PROFILE_NAME
}

/*
# Run EC2 instance 'TomCat'
resource "aws_instance" "frontend" {
  ami             = var.OS_IMAGE_ID
  instance_type   = "t2.micro"
  key_name        = "vpro-key"
  subnet_id       = local.sandbox_subnet_id
  security_groups = [ aws_security_group.sg_front.id ]
  associate_public_ip_address = false
  iam_instance_profile = module.instance_profile_setup.instance_profile_name

  credit_specification {
    cpu_credits   = "standard"
  }
  tags = {
    Name    = "app01"
    Server  = "TomCat"
  }
  user_data = templatefile("${path.module}/vm-template-scripts/tomcat-template-script.sh", {
    db_ip           = var.DATABASE_IP
    mc_ip           = var.MEMCACHE_IP
    rmq_ip          = var.RABBITMQ_IP
    S3_BUCKET_NAME  = var.BUCKET_NAME
  })
}


# Run EC2 instance 'MySQL'
resource "aws_instance" "backend" {
  ami                         = var.OS_IMAGE_ID
  instance_type               = "t2.micro"
  key_name                    = "vpro-key"
  subnet_id                   = local.sandbox_subnet_id
  associate_public_ip_address = true  # ------ CHANGED! ------
  private_ip                  = var.DATABASE_IP
  iam_instance_profile = module.instance_profile_setup.instance_profile_name

  security_groups = [
    aws_security_group.sg_back.id
  ]
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Name    = "db01"
    Server  = "MySQL"
  }
  user_data = templatefile("${path.module}/vm-template-scripts/db-template-script.sh", {
    DATABASE_PASS  = var.DB_PASS
    S3_BUCKET_NAME = var.BUCKET_NAME
  })
}


# Run EC2 instance 'memcache'
resource "aws_instance" "memcache" {
  ami                         = var.OS_IMAGE_ID
  instance_type               = "t2.micro"
  key_name                    = "vpro-key"
  subnet_id                   = local.sandbox_subnet_id
  associate_public_ip_address = true  # ------ CHANGED! ------
  private_ip                  = var.MEMCACHE_IP

  security_groups = [
    aws_security_group.sg_back.id
  ]
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Name    = "mc01"
    Server  = "MemcacheD"
  }
  user_data = templatefile("${path.module}/vm-template-scripts/mc-template-script.sh", {
    db_ip   = var.DATABASE_IP
    mc_ip   = var.MEMCACHE_IP
    rmq_ip  = var.RABBITMQ_IP
  })
}


# Run EC2 instance 'rabbitmq' on  -= Amazon CentOS Stream 9 =-
resource "aws_instance" "rabbitmq" {
  ami                         = "ami-0df2a11dd1fe1f8e3"
  instance_type               = "t2.small"
  key_name                    = "vpro-key"
  subnet_id                   = local.sandbox_subnet_id
  associate_public_ip_address = true  # ------ CHANGED! ------
  private_ip                  = var.RABBITMQ_IP

  security_groups = [
    aws_security_group.sg_back.id
  ]
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Name    = "rmq01"
    Server  = "RabbitMQ"
  }
  user_data = templatefile("${path.module}/vm-template-scripts/rmq-template-script.sh", {
    db_ip   = var.DATABASE_IP
    mc_ip   = var.MEMCACHE_IP
    rmq_ip  = var.RABBITMQ_IP
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
  iam_instance_profile = module.instance_profile_setup.instance_profile_name

  security_groups = [ 
    aws_security_group.sg_front.id, 
    aws_security_group.sg_jump.id
  ]
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Name    = "jump01"
    Server  = "Bastion"
  }
  user_data = templatefile("${path.module}/vm-template-scripts/jump-template-script.sh", {
    db_ip           = var.DATABASE_IP
    mc_ip           = var.MEMCACHE_IP
    rmq_ip          = var.RABBITMQ_IP
    S3_BUCKET_NAME  = var.BUCKET_NAME
  })
}
