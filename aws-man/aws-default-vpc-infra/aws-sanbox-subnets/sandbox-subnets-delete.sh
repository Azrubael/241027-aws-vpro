#!/bin/bash

VPC_NAME="DEFAULT-VPC"
FRONTEND_NAME="FRONTEND-subnet"
FRONTEND_SG="FRONTEND-sg"
BACKEND_NAME="BACKEND-subnet"
BACKEND_SG="BACKEND-sg"

# Get subnets ID 
FRONTEND_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=$FRONTEND_NAME --query 'Subnets[*].SubnetId' --output text)
echo "$FRONTEND_NAME has ID: $FRONTEND_ID"
BACKEND_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=$BACKEND_NAME --query 'Subnets[*].SubnetId' --output text)
echo "$BACKEND_NAME has ID: $BACKEND_ID"

# Get Security Groups ID
FRONTEND_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values="${FRONTEND_NAME}-sg" --query 'SecurityGroups[*].GroupId' --output text)
BACKEND_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values="${BACKEND_NAME}-sg" --query 'SecurityGroups[*].GroupId' --output text)

# Delete subnets
if [ -n "$FRONTEND_ID" ]; then
    aws ec2 delete-subnet --subnet-id $FRONTEND_ID
    echo "Deleted $FRONTEND_NAME subnet: $FRONTEND_ID"
fi

if [ -n "$BACKEND_ID" ]; then
    aws ec2 delete-subnet --subnet-id $BACKEND_ID
    echo "Deleted $BACKEND_NAME subnet: $BACKEND_ID"
fi

# Delete security groups
if [ -n "$FRONTEND_SG_ID" ]; then
    aws ec2 delete-security-group --group-id $FRONTEND_SG_ID
    echo "Deleted $FRONTEND_NAME security group: $FRONTEND_SG_ID"
fi

if [ -n "$BACKEND_SG_ID" ]; then
    aws ec2 delete-security-group --group-id $BACKEND_SG_ID
    echo "Deleted $BACKEND_NAME security group: $BACKEND_SG_ID"
fi

