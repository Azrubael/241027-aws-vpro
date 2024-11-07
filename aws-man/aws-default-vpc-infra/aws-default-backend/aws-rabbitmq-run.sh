#!/bin/bash
# Amazon CentOS Stream 9 (x86_64)
# https://aws.amazon.com/marketplace/pp/prodview-k66o7o642dfve?ref_=aws-mp-console-subscription-detail
# AMI ID: ami-0df2a11dd1fe1f8e3

source ./sandbox_env
SUBNET=$BACKEND_NAME
TARGET_IP=$RABBITMQ_IP

HOSTS="### custom IPs
$DATABASE_IP	db01
$MEMCACHE_IP	mc01
$RABBITMQ_IP	rmq01
###"

RMQ_CONF='echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'

# Checking IP address availability
if ping -c 1 $TARGET_IP &> /dev/null; then
    echo "IP $TARGET_IP is already busy. Stop execution."
    exit 1
fi

# Get IDs of backend subnet and security group
SUBNET_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=$SUBNET --query 'Subnets[*].SubnetId' --output text)
BACKEND_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=$BACKEND_SG --query 'SecurityGroups[*].GroupId' --output text)

USER_DATA_SCRIPT="#!/bin/bash
set -e
sudo yum install epel-release -y
sudo dnf -y install centos-release-rabbitmq-38
sudo dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
sudo systemctl enable --now rabbitmq-server
sudo systemctl start rabbitmq-server
sudo sh -c $RMQ_CONF
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo systemctl restart rabbitmq-server
echo \"$HOSTS\" >> /etc/hosts
"

echo "$USER_DATA_SCRIPT"

USER_DATA_ENCODED=$(echo "$USER_DATA_SCRIPT" | base64)

aws ec2 run-instances \
    --image-id "ami-0df2a11dd1fe1f8e3" \
    --instance-type "t2.small" \
    --key-name "vpro-key" \
    --network-interfaces "{
            \"SubnetId\":\"$SUBNET_ID\",
            \"AssociatePublicIpAddress\":false,
            \"DeviceIndex\":0,
            \"Groups\":[\"$BACKEND_SG_ID\"],
            \"PrivateIpAddress\":\"$TARGET_IP\"
        }" \
    --iam-instance-profile Name="$INSTANCE_PROFILE_NAME" \
    --credit-specification '{"CpuCredits":"standard"}' \
    --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"rmq01"},{"Key":"Server","Value":"RabbitMQ"}]}' \
    --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"optional"}' \
    --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":false,"EnableResourceNameDnsAAAARecord":false}' \
    --count "1" \
    --user-data "$USER_DATA_ENCODED" &&


if [ $? -eq 0 ]; then
    echo "An EC2 instance of RabbitMQ server is running."
else
    echo "Something went wrong with RabbitMQ server."
fi