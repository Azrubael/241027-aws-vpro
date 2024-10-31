#!/bin/bash
# The acript to setup the sanbox subnets in the DEFAULT VPC

VPC_NAME="DEFAULT-VPC"
VPC_CIDR=""
SANDBOX_NAME="SANDBOX-subnet"
SANDBOX_CIDR=""
WAN_CIDR="0.0.0.0/0"

FRONTEND_NAME="FRONTEND-subnet"
FRONTEND_SG="FRONTEND-sg"
FRONTEND_CIDR="172.31.18.0/24"

BACKEND_NAME="BACKEND-subnet"
BACKEND_SG="BACKEND-sg"
BACKEND_CIDR="172.31.19.0/24"


echo "### [1] Get ID of the default VPC"
VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=$VPC_NAME --query 'Vpcs[*].VpcId' --output text)
VPC_CIDR=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=$VPC_NAME --query 'Vpcs[*].CidrBlock' --output text)

# Check if the default VPC is accessible
sleep 5
if [ -z "$VPC_ID" ]; then
    echo "Cannot find the VPC with name $VPC_NAME"
    exit 1
else
    echo "Found $VPC_NAME network: $VPC_ID with CIDR: $VPC_CIDR"
fi


echo
echo "### [2] Get Availability Zone of sandbox subnet"
SANDBOX_AZ=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=$SANDBOX_NAME --query 'Subnets[*].AvailabilityZone' --output text)
SANDBOX_CIDR=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=$SANDBOX_NAME --query 'Subnets[*].CidrBlock' --output text)

# Check if the sandbox subnet is accessible
if [ -z "$SANDBOX_AZ" ]; then
    echo "Cannot find the VPC with name $SANDBOX_NAME."
else
    echo "The subnet $SANDBOX_NAME with CIDR:$SANDBOX_CIDR is in the Availability Zone: $SANDBOX_AZ"
fi


echo
echo "### [3] Create $FRONTEND_NAME..."
aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "$FRONTEND_CIDR" \
    --availability-zone "$SANDBOX_AZ" \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$FRONTEND_NAME}]"

# Get ID frontend subnet
FRONTEND_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=$FRONTEND_NAME --query 'Subnets[*].SubnetId' --output text)
echo "Created $FRONTEND_NAME: $FRONTEND_ID"


echo
echo "### [4] Create $BACKEND_NAME..."
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $BACKEND_CIDR \
    --availability-zone $SANDBOX_AZ \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$BACKEND_NAME}]"

# Get ID backend subnet
BACKEND_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=$BACKEND_NAME --query 'Subnets[*].SubnetId' --output text)
echo "Created $BACKEND_NAME: $BACKEND_ID"


echo
echo "### [5] Create $FRONTEND_SG security group"
aws ec2 create-security-group \
    --group-name $FRONTEND_SG \
    --description "Security group for frontend instances" \
    --vpc-id $VPC_ID

# Get ID frontend Security Group
FRONTEND_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=$FRONTEND_SG --query 'SecurityGroups[*].GroupId' --output text)


echo
echo "### [6] Create $FRONTEND_SG rules"
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
echo "### [7] Create $BACKEND_SG security group"
aws ec2 create-security-group \
    --group-name $BACKEND_SG \
    --description "Security group for backend services" \
    --vpc-id $VPC_ID

# Get ID backend Security Group
BACKEND_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=$BACKEND_SG --query 'SecurityGroups[*].GroupId' --output text)

echo
echo "### [8] Create $BACKEND_SG rules"
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
