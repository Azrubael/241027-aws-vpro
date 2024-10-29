#!/bin/bash

APP="vpro"
VPC_NAME="${APP}-VPC"
FRONTEND="${APP}-frontend"
BACKEND="${APP}-backend"

# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=$VPC_NAME --query 'Vpcs[*].VpcId' --output text)

# Get ID Security Groups
FRONTEND_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values="${FRONTEND}-sg" --query 'SecurityGroups[*].GroupId' --output text)
BACKEND_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values="${BACKEND}-sg" --query 'SecurityGroups[*].GroupId' --output text)

# Get subnets ID
FRONTEND_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values="${FRONTEND}-subnet" --query 'Subnets[*].SubnetId' --output text)
BACKEND_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values="${BACKEND}-subnet" --query 'Subnets[*].SubnetId' --output text)

# Delete subnets
if [ -n "$FRONTEND_ID" ]; then
    aws ec2 delete-subnet --subnet-id $FRONTEND_ID
    echo "Deleted $FRONTEND subnet: $FRONTEND_ID"
fi

if [ -n "$BACKEND_ID" ]; then
    aws ec2 delete-subnet --subnet-id $BACKEND_ID
    echo "Deleted $BACKEND subnet: $BACKEND_ID"
fi

# Delete security groups
if [ -n "$FRONTEND_SG_ID" ]; then
    aws ec2 delete-security-group --group-id $FRONTEND_SG_ID
    echo "Deleted $FRONTEND security group: $FRONTEND_SG_ID"
fi

if [ -n "$BACKEND_SG_ID" ]; then
    aws ec2 delete-security-group --group-id $BACKEND_SG_ID
    echo "Deleted $BACKEND security group: $BACKEND_SG_ID"
fi

# Delete VPC
if [ -n "$VPC_ID" ]; then
    aws ec2 delete-vpc --vpc-id $VPC_ID
    echo "Deleted $VPC_NAME network: $VPC_ID"
fi
