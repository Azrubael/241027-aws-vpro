variable "VPC_NAME" {
  description = "VPC tag 'Name'"
  type        = string
  default     = "DEFAULT-VPC"
}

variable "WAN_IP" {
  description = "Public IP address to reach the world outside"
  type        = string
  default     = "0.0.0.0/0"
}

variable "FRONTEND_CIDR" {
  description = "Frontend subnet CIDR"
  type        = string
  default     = "172.31.48.0/20"
}

variable "FRONTEND_SUBNET_NAME" {
  description = "Value of the tag 'Name' for the frontend subnet"
  type        = string
  default     = "FRONTEND-subnet"
}

variable "FRONTEND_SG" {
  description = "Value of the tag 'Name' for the frontend security group"
  type        = string
  default     = "FRONTEND-sg"
}

variable "FRONTEND_SG_NOTE" {
  description = "Frontend sunet security group description"
  type        = string
  default     = "Frontend sandbox security group for TomCat servers"
}

variable "FRONTEND_PORTS" {
  description = "An array containing data for creating frontend security group rules"
  type        = list(list(any))
  default = [
    ["tcp", 8080],
    ["tcp", 22]
  ]
}

variable "BACKEND_CIDR" {
  description = "Backend subnet CIDR"
  type        = string
  default     = "172.31.64.0/20"
}

variable "BACKEND_SUBNET_NAME" {
  description = "Value of the tag 'Name' for the frontend subnet"
  type        = string
  default     = "BACKEND-subnet"
}

variable "BACKEND_SG" {
  description = "Value of the tag 'Name' for the frontend security group"
  type        = string
  default     = "BACKEND-sg"
}

variable "BACKEND_SG_NOTE" {
  description = "Backend sandbox security group for DB, MemcacheD and RabbitMQ servers"
  type        = string
  default     = "Frontend sandbox security group for TomCat servers"
}

variable "BACKEND_PORTS" {
  description = "An array containing data for creating backend security group rules"
  type        = list(list(any))
  default = [
    ["tcp", 22],
    ["tcp", 11211],
    ["tcp", 5672],
    ["tcp", 3306],
    ["all", 0]
  ]
}

variable "DATABASE_IP" {
  description = "MySQL database IP"
  type        = string
  default     = "172.31.64.7"
}

variable "MEMCACHE_IP" {
  description = "MemcacheD server IP"
  type        = string
  default     = "172.31.64.8"
}

variable "RABBITMQ_IP" {
  description = "RabbitMQ server IP"
  type        = string
  default     = "172.31.64.9"
}

variable "BASTION_IP" {
  description = "Jump server IP"
  type        = string
  default     = "172.31.48.249"
}

variable "OS_IMAGE_ID" {
  description = "OS image id for the EC2 instances"
  type        = string
  default     = "ami-0ddc798b3f1a5117e"
}

variable "BUCKET_NAME" {
  description = "S3 bucket name"
  type        = string
  default     = "az-20241102"
}

variable "BUCKET_REGION" {
  description = "S3 bucket region"
  type        = string
  default     = "us-east-1"
}

variable "BUCKET_ROLE_NAME" {
  description = "S3 bucket role name"
  type        = string
  default     = "EC2S3ReadOnlyRole"
}

variable "BUCKET_POLICY_NAME" {
  description = "S3 bucket policy name"
  type        = string
  default     = "EC2S3ReadOnlyPolicy"
}

variable "INSTANCE_PROFILE_NAME" {
  description = "Instance profile name for connetion EC2 instances to S3 bucket"
  type        = string
  default     = "EC2S3ReadOnlyProfile"
}

variable "PATH_TO_PUBLIC_KEY" {
  description = "Path to the public key used for ssh access fron jumpserver"
  type        = string
  default     = "~/.aws/doorward.pub"
}