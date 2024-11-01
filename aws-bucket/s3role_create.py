#!/usr/bin/env python3
"""
This script creates an S3 bucket with a predefined name pattern,
an IAM role, and a policy for accessing S3 in the 'DEFAULT-VPC' network,
and uploads a few files to it.
"""

import boto3
import datetime
import os
import json

bucket_name = f"az-{datetime.datetime.now().strftime('%Y%m%d')}"
role_name = "EC2S3AccessRole"
policy_name = "S3AccessPolicy"

# Initiate the S3 and IAM clients
s3_client = boto3.client('s3', region_name='us-east-1')
iam_client = boto3.client('iam')

# Create the S3 bucket
s3_client.create_bucket(Bucket=bucket_name)

# Создание trust policy для IAM роли
trust_policy = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}

# Create the IAM role
iam_client.create_role(
    RoleName=role_name,
    AssumeRolePolicyDocument=json.dumps(trust_policy)
)

# Create the S3 policy for accessing S3
s3_policy = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                f"arn:aws:s3:::{bucket_name}",
                f"arn:aws:s3:::{bucket_name}/*"
            ]
        }
    ]
}

# Apply the policy to the role
iam_client.put_role_policy(
    RoleName=role_name,
    PolicyName=policy_name,
    PolicyDocument=json.dumps(s3_policy)
)

# Upload predefined files to S3
files = [
    "artifact/vpro.zip",
    "artifact/vpro.z01",
    "artifact/vpro.z02",
    "env/db_env",
    "aws-vm/application.properties",
    "aws-vm/1-mysql.sh",
    "aws-vm/2-memcached.sh",
    "aws-vm/3-rabbitmq.sh",
    "aws-vm/4-tomcat.sh",
    "aws-vm/5-nginx.sh"
]

for file in files:
    file_path = os.path.join("..", "..", file)
    if os.path.isfile(file_path):
        print(f"Uploading {file_path} to s3://{bucket_name}/")
        try:
            s3_client.upload_file(file_path, bucket_name, file)
            print(f"{file} successfully uploaded to s3://{bucket_name}/")
        except Exception as e:
            print(f"Failed to upload {file} to s3://{bucket_name}/: {e}")
    else:
        print(f"Warning: {file} doesn't exist and cannot be uploaded.")

# Listing contents of S3 bucket
print(f"\n### Listing contents of s3://{bucket_name}")
response = s3_client.list_objects_v2(Bucket=bucket_name)
if 'Contents' in response:
    for obj in response['Contents']:
        print(obj['Key'])
else:
    print("Bucket is empty.")
