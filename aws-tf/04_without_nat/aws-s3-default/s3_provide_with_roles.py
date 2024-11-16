#!/usr/bin/env python3
"""
This script creates an S3 bucket with a predefined name pattern,
an IAM role, and a policy for accessing S3 in the 'DEFAULT-VPC' network,
and uploads a few files to it.
"""

import boto3
import os
import json
from botocore.exceptions import ClientError
from dotenv import load_dotenv


# Check if the IAM role exists
def role_exists(role_name: str, iam_client: boto3.client) -> bool:
    """
    Checks if an IAM role with the specified name exists.
    """
    try:
        iam_client.get_role(RoleName=role_name)
        return True
    except iam_client.exceptions.NoSuchEntityException:
        return False


# Check if the IAM policy exists
def policy_exists(role_name: str, policy_name: str, iam_client: boto3.client) -> bool:
    """
    Checks if a specific IAM policy exists for a given IAM role.

    Parameters:
        role_name (str): The name of the IAM role.
        policy_name (str): The name of the policy to check.
        iam_client (boto3.client): The Boto3 IAM client used to interact with AWS IAM.

    Returns:
        bool: True if the policy exists for the role, False if it does not exist 
              or if the role itself does not exist.
    """
    try:
        iam_client.list_role_policies(RoleName=role_name)
        policies = iam_client.list_role_policies(RoleName=role_name)['PolicyNames']
        return policy_name in policies
    except iam_client.exceptions.NoSuchEntityException:
        return False


def check_s3_bucket_exists(bucket_name: str, s3_client: boto3.client) -> bool:
    """
    Check if an S3 bucket with the given name exists.

    :param bucket_name: The name of the S3 bucket to check.
    :return: True if the bucket exists, False otherwise.
    """

    try:
        s3_client.head_bucket(Bucket=bucket_name)
        return True
    except ClientError as e:
        # If a 404 error is raised, the bucket does not exist
        if e.response['Error']['Code'] == '404':
            return False
        # If a different error is raised, re-raise the exception
        raise


def create_s3_bucket_with_policy(bucket_name: str, bucket_policy: dict, s3_client: boto3.client) -> None:
    """
    Creates an S3 bucket and sets the specified bucket policy on it.

    Parameters:
        bucket_name (str): The name of the bucket to create.
        bucket_policy (dict): The policy to set on the newly created bucket.
        s3_client (boto3.client): The Boto3 S3 client used to interact with AWS S3.

    Returns:
        None
    """
    try:
        if check_s3_bucket_exists(bucket_name, s3_client):
            print(f"Bucket '{bucket_name}' already exists.")
            return
        s3_client.create_bucket(Bucket=bucket_name)
        print(f"Bucket '{bucket_name}' created successfully.")
    except ClientError as e:
        print(f"Error creating bucket: {e}")
        return

    # Set the bucket policy
    bucket_policy_json = json.dumps(bucket_policy)
    try:
        s3_client.put_bucket_policy(Bucket=bucket_name, Policy=bucket_policy_json)
        print(f"Bucket policy added to '{bucket_name}'.")
    except ClientError as e:
        print(f"Error setting bucket policy: {e}")
    

if __name__ == "__main__":
    load_dotenv(dotenv_path=f'{os.environ.get("HOME")}/.aws/devops_id')
    account_id = os.environ.get('AWSN')
    load_dotenv(dotenv_path='../../.env/sandbox_env')
    bucket_name= os.environ.get('BUCKET_NAME')
    region = os.environ.get('BUCKET_REGION')

    role_name = os.environ.get('BUCKET_ROLE_NAME')
    policy_name = os.environ.get('BUCKET_POLICY_NAME')
    files = [
        "artifact/vpro.zip",
        "artifact/vpro.z01",
        "artifact/vpro.z02",
        "artifact/application.properties",
        "artifact/mysql_check.py"
    ]

    # Define the trust policy for the IAM role
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

    # Define the S3 bucket policy
    bucket_policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Action": [
                    "s3:GetObject",
                    "s3:ListBucket"
                ],
                "Resource": [
                    f"arn:aws:s3:::{bucket_name}",
                    f"arn:aws:s3:::{bucket_name}/*"
                ],
                "Condition": {
                    "StringEquals": {
                        "aws:SourceArn": f"arn:aws:iam::{account_id}:role/{role_name}"
                    }
                }
            }
        ]
    }

    s3_client = boto3.client('s3', region)
    iam_client = boto3.client('iam')

    # Create the IAM role 'role_name' if it doesn't exist
    if not role_exists(role_name, iam_client):
        iam_client.create_role(
            RoleName=role_name,
            AssumeRolePolicyDocument=json.dumps(trust_policy)
        )
        print(f"Role '{role_name}' created.")
    else:
        print(f"Role '{role_name}' already exists.")

    # Create the IAM policy for accessing S3
    iam_policy = {
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
    if not policy_exists(role_name, policy_name, iam_client):
        iam_client.put_role_policy(
            RoleName=role_name,
            PolicyName=policy_name,
            PolicyDocument=json.dumps(iam_policy)
        )
        print(f"Policy '{policy_name}' added to role '{role_name}'.")
    else:
        print(f"Policy '{policy_name}' already exists for role '{role_name}'.")


    # Create the S3 bucket
    create_s3_bucket_with_policy(bucket_name, bucket_policy, s3_client)


    # Upload predefined files to S3
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

