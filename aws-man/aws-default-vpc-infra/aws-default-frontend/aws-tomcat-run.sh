#!/bin/bash

source ./sandbox_env
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
aws s3 cp s3://${BUCKET_NAME}/aws-vm/4-tomcat.sh .
aws s3 cp s3://${BUCKET_NAME}/aws-wm/application.properties .
aws s3 cp s3://${BUCKET_NAME}/artifact/vpro.zip .
aws s3 cp s3://${BUCKET_NAME}/artifact/vpro.z01 .
aws s3 cp s3://${BUCKET_NAME}/artifact/vpro.z02 .
bash 4-tomcat.sh"

USER_DATA_ENCODED=$(echo "$USER_DATA_SCRIPT" | base64)

aws ec2 run-instances \
    --image-id "ami-06b21ccaeff8cd686" \
    --instance-type "t2.micro" \
    --key-name "vpro-key" \
    --network-interfaces "{
            \"SubnetId\":\"$SUBNET_ID\",
            \"AssociatePublicIpAddress\":true,
            \"DeviceIndex\":0,
            \"Groups\":[\"$FRONTEND_SG_ID\"]
        }" \
    --iam-instance-profile Name="$INSTANCE_PROFILE_NAME" \
    --credit-specification '{"CpuCredits":"standard"}' \
    --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"app01"},{"Key":"Server","Value":"TomCat"}]}' \
    --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"optional"}' \
    --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":false,"EnableResourceNameDnsAAAARecord":false}' \
    --count "1" \
    --user-data "$USER_DATA_ENCODED"

if [ $? -eq 0 ]; then
    echo "An EC2 instance of TomCat server is running."
else
    echo "Something went wrong TomCat server."
fi
