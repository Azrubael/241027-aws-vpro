#!/bin/bash
# The script to create and setup a completely new VPC

APP="vpro"
VPC_NAME="${APP}-VPC"
VPC_CIDR="172.19.0.0/16"
WAN_CIDR="0.0.0.0/0"

FRONTEND="${APP}-frontend"
FRONTEND_NAME="${FRONTEND}-subnet"
FRONTEND_SG="${FRONTEND}-sg"
FRONTEND_CIDR="172.19.1.0/24"
FRONTEND_AZ="us-east-1b"

BACKEND="${APP}-backend"
BACKEND_NAME="${BACKEND}-subnet"
BACKEND_SG="${BACKEND}-sg"
BACKEND_CIDR="172.19.100.0/24"
BACKEND_AZ="us-east-1b"

echo "### Create VPC"
aws ec2 create-vpc \
    --cidr-block $VPC_CIDR \
    --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$VPC_NAME}]"
sleep 5

# Get ID of created VPC
VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=$VPC_NAME --query 'Vpcs[*].VpcId' --output text)
echo "Created $VPC_NAME network: $VPC_ID"

echo
echo "### Create $FRONTEND_NAME..."
aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "$FRONTEND_CIDR" \
    --availability-zone "$FRONTEND_AZ" \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$FRONTEND_NAME}]"

# Get ID frontend subnet
FRONTEND_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=$FRONTEND_NAME --query 'Subnets[*].SubnetId' --output text)
echo "Created $FRONTEND_NAME: $FRONTEND_ID"

echo
echo "### Create $BACKEND_NAME..."
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $BACKEND_CIDR \
    --availability-zone $BACKEND_AZ \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$BACKEND_NAME}]"

# Get ID backend subnet
BACKEND_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=$BACKEND_NAME --query 'Subnets[*].SubnetId' --output text)
echo "Created $BACKEND_NAME: $BACKEND_ID"

echo
echo "### Create $FRONTEND_SG"
aws ec2 create-security-group \
    --group-name $FRONTEND_SG \
    --description "Security group for frontend instances" \
    --vpc-id $VPC_ID

# Get ID frontend Security Group
FRONTEND_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=$FRONTEND_SG --query 'SecurityGroups[*].GroupId' --output text)

echo
echo "### Create $FRONTEND_SG rules"
aws ec2 authorize-security-group-ingress \
    --group-id $FRONTEND_SG_ID \
    --protocol tcp \
    --port 8080 \
    --cidr $WAN_CIDR
aws ec2 authorize-security-group-ingress \
    --group-id $FRONTEND_SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr $WAN_CIDR
aws ec2 authorize-security-group-ingress \
    --group-id $FRONTEND_SG_ID \
    --protocol all \
    --port -1 \
    --cidr $WAN_CIDR

echo
echo "### Create $BACKEND_SG"
aws ec2 create-security-group \
    --group-name $BACKEND_SG \
    --description "Security group for backend services" \
    --vpc-id $VPC_ID

# Get ID backend Security Group
BACKEND_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=$BACKEND_SG --query 'SecurityGroups[*].GroupId' --output text)

echo
echo "### Create $BACKEND_SG rules"
aws ec2 authorize-security-group-ingress \
    --group-id $BACKEND_SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr $WAN_CIDR
aws ec2 authorize-security-group-ingress \
    --group-id $BACKEND_SG_ID \
    --protocol tcp \
    --port 11211 \
    --cidr $FRONTEND_CIDR
aws ec2 authorize-security-group-ingress \
    --group-id $BACKEND_SG_ID \
    --protocol tcp \
    --port 5672 \
    --cidr $FRONTEND_CIDR
aws ec2 authorize-security-group-ingress \
    --group-id $BACKEND_SG_ID \
    --protocol tcp \
    --port 3306 \
    --cidr $FRONTEND_CIDR
aws ec2 authorize-security-group-ingress \
    --group-id $BACKEND_SG_ID \
    --protocol all \
    --port -1 \
    --cidr $FRONTEND_CIDR

echo
echo "Subnets and Security Groups created!"
aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID --query 'Subnets[*].{ID:SubnetId,Name:Tags[?Key==`Name`].Value | [0],CIDR:CidrBlock}' --output table