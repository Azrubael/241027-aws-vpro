#!/bin/bash

source ./sandbox_env
S3_URL="https://az-20241029.s3.us-east-1.amazonaws.com"
SUBNET=$FRONTEND_NAME

CUSTOM_IPs="### custom IPs
$DATABASE_IP	db01
$MEMCACHED_IP	mc01
$RABBITMQ_IP	rmq01
###"

# Get IDs of frontend subnet and security group
SUBNET_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=$SUBNET --query 'Subnets[*].SubnetId' --output text)
FRONTEND_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=$FRONTEND_SG --query 'SecurityGroups[*].GroupId' --output text)

USER_DATA_SCRIPT="#!/bin/bash
sudo echo $CUSTOM_IPs >> /etc/hosts
mkdir -p /tmp/provisioning
cd /tmp/provisioning
curl -O $S3_URL/aws-vm/4-tomcat.sh
curl -O $S3_URL/aws-wm/application.properties
curl -O $S3_URL/artifact/vpro.zip
curl -O $S3_URL/artifact/vpro.z01
curl -O $S3_URL/artifact/vpro.z02
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
    --iam-instance-profile Name="EC2S3AccessRole" \
    --credit-specification '{"CpuCredits":"standard"}' \
    --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"app01"},{"Key":"Server","Value":"TomCat"}]}' \
    --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"optional"}' \
    --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":false,"EnableResourceNameDnsAAAARecord":false}' \
    --count "1" \
    --user-data "$USER_DATA_ENCODED" && \
echo "Success!"
