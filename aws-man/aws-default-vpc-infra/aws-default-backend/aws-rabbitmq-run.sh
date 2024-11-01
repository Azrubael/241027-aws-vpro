#!/bin/bash

S3_SCRIPT_URL="https://az-20241029.s3.us-east-1.amazonaws.com/3-rabbitmq.sh"
TARGET_IP="172.19.100.9"
SUBNET="vpro-backend-subnet"
BACKEND_SG="vpro-backend-sg"

# Checking IP address availability
if ping -c 1 $TARGET_IP &> /dev/null; then
    echo "IP $TARGET_IP available."
else
    echo "IP $TARGET_IP unavailable. Stop execution."
    exit 1
fi

# Get IDs of backend subnet and security group
SUBNET_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=$SUBNET --query 'Subnets[*].SubnetId' --output text)
BACKEND_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=$BACKEND_SG --query 'SecurityGroups[*].GroupId' --output text)

USER_DATA_SCRIPT="#!/bin/bash
curl -O $S3_SCRIPT_URL
bash 1-mysql.sh"

USER_DATA_ENCODED=$(echo "$USER_DATA_SCRIPT" | base64)

aws ec2 run-instances \
    --image-id "ami-0ddc798b3f1a5117e" \
    --instance-type "t2.micro" \
    --key-name "vpro-key" \
    --network-interfaces "{
            \"SubnetId\":\"$SUBNET_ID\",
            \"AssociatePublicIpAddress\":false,
            \"DeviceIndex\":0,
            \"Groups\":[\"$BACKEND_SG_ID\"],
            \"PrivateIpAddress\":\"$TARGET_IP\"
        }" \
    --credit-specification '{"CpuCredits":"standard"}' \
    --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"rmq01"},{"Key":"Server","Value":"RabbitMQ"}]}' \
    --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"optional"}' \
    --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":false,"EnableResourceNameDnsAAAARecord":false}' \
    --count "1" \
    --user-data "$USER_DATA_ENCODED" && \
echo "Success!"
