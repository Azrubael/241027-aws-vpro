#!/bin/bash

S3_SCRIPT_URL="https://az-20241029.s3.us-east-1.amazonaws.com/1-mysql.sh"

USER_DATA_SCRIPT="#!/bin/bash
curl -O $S3_SCRIPT_URL
bash 1-mysql.sh"

USER_DATA_ENCODED=$(echo "$USER_DATA_SCRIPT" | base64)

aws ec2 run-instances \
    --image-id "ami-0ddc798b3f1a5117e" \
    --instance-type "t2.micro" \
    --key-name "vpro-key" \
    --network-interfaces '{"SubnetId":"subnet-0fa648f8fb0a64d63","AssociatePublicIpAddress":false,"DeviceIndex":0,"Groups":["sg-0d7b1ff6919124be0"]}' \
    --credit-specification '{"CpuCredits":"standard"}' \
    --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"db01"},{"Key":"Server","Value":"MySQL"}]}' \
    --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"optional"}' \
    --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":false,"EnableResourceNameDnsAAAARecord":false}' \
    --count "1" \
    --user-data "$USER_DATA_ENCODED" && \
echo "Success!"