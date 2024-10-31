#!/bin/bash

source ../sandbox_env
S3_SCRIPT_URL="https://az-20241029.s3.us-east-1.amazonaws.com/4-tomcat.sh"
SUBNET=$FRONTEND_NAME

# Get IDs of frontend subnet and security group
SUBNET_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=$SUBNET --query 'Subnets[*].SubnetId' --output text)
FRONTEND_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=$FRONTEND_SG --query 'SecurityGroups[*].GroupId' --output text)

USER_DATA_SCRIPT="#!/bin/bash
curl -O $S3_SCRIPT_URL
bash 4-tomcat.sh"

USER_DATA_ENCODED=$(echo "$USER_DATA_SCRIPT" | base64)

aws ec2 run-instances \
    --image-id "ami-0ddc798b3f1a5117e" \
    --instance-type "t2.micro" \
    --key-name "vpro-key" \
    --network-interfaces "{
            \"SubnetId\":\"$SUBNET_ID\",
            \"AssociatePublicIpAddress\":true,
            \"DeviceIndex\":0,
            \"Groups\":[\"$FRONTEND_SG_ID\"]
        }" \
    --credit-specification '{"CpuCredits":"standard"}' \
    --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"app01"},{"Key":"Server","Value":"TomCat"}]}' \
    --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"optional"}' \
    --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":false,"EnableResourceNameDnsAAAARecord":false}' \
    --count "1" \
    --user-data "$USER_DATA_ENCODED" && \
echo "Success!"
