variable "VPC_NAME" {
  description = "VPC tag 'Name'"
  type        = string
  default     = "DEFAULT-VPC"
}

variable "WAN_CIDR" {
  description = "Public IP address to reach the world outside"
  type        = string
  default     = "0.0.0.0/0"
}

variable "SANDBOX_CIDR" {
  description = "Sandbox first subnet CIDR"
  type        = string
  default     = "172.31.32.0/20"
}

variable "SANDBOX_SUBNET_NAME" {
  description = "Value of the tag 'Name' for the sandbox subnet"
  type        = string
  default     = "SANDBOX-32-subnet"
}

variable "SANDBOX_16_CIDR" {
  description = "Sandbox second subnet CIDR"
  type        = string
  default     = "172.31.16.0/20"
}

variable "SANDBOX_16_SUBNET_NAME" {
  description = "Value of the tag 'Name' for the sandbox subnet"
  type        = string
  default     = "SANDBOX-16-subnet"
}

variable "DATABASE_IP" {
  description = "MySQL database IP"
  type        = string
  default     = "172.31.32.7"
}

variable "MEMCACHE_IP" {
  description = "MemcacheD server IP"
  type        = string
  default     = "172.31.32.8"
}

variable "RABBITMQ_IP" {
  description = "RabbitMQ server IP"
  type        = string
  default     = "172.31.32.9"
}

variable "BASTION_IP" {
  description = "Jump server IP"
  type        = string
  default     = "172.31.32.249"
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

variable "FRONTEND_INGRESS" {
  description = "An array containing data for creating frontend security group rules"
  type        = list(list(any))
  default = [
    ["tcp", 8080],
    ["udp", 8080]
  ]
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

variable "BACKEND_INGRESS" {
  description = "An array containing data for creating backend security group rules"
  type        = list(list(any))
  default = [
    ["tcp", 22],
    ["tcp", 11211],
    ["tcp", 5672],
    ["tcp", 3306]
  ]
}

variable "BACKEND_EGRESS" {
  description = "An array containing data for creating backend security group rules"
  type        = list(list(any))
  default = [
    ["tcp", 80],
    ["tcp", 443],
    ["icmp", 0]
  ]
}

variable "OS_IMAGE_ID" {
  description = "OS image id for the EC2 instances"
  type        = string
  default     = "ami-0984f4b9e98be44bf"
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
  default     = "EC2S3ReadOnlyRoleTF"
}

variable "BUCKET_POLICY_NAME" {
  description = "S3 bucket policy name to allow access to S3 bucket"
  type        = string
  default     = "EC2S3ReadOnlyPolicyTF"
}

variable "INSTANCE_PROFILE_NAME" {
  description = "Instance profile name for connetion EC2 instances to S3 bucket"
  type        = string
  default     = "EC2S3ReadOnlyProfileTF"
}

variable "PATH_TO_PUBLIC_KEY" {
  description = "Path to the public key used for ssh access fron jumpserver"
  type        = string
  default     = "~/.aws/doorward.pub"
}

variable "DB_PASS" {
  description = "Database password"
  type        = string
}

variable "SP_PUBLIC_KEY" {
  description = "Path to the public key used for ssh access from jumpserver"
  type        = string
}

variable "SP_PRIVATE_KEY" {
  description = "Path to the private key used for ssh access from jumpserver"
  type        = string
}

variable "SP_PASS" {
  description = "Doorward's password"
  type        = string
}

variable "LB_INGRESS" {
  description = "An array containing data for creating a Load Balancer security group rules"
  type        = list(list(any))
  default = [
    ["tcp", 80],
    ["tcp", 443],
    ["icmp", 0]
  ]
}