#!/usr/bin/env python3
"""
This script deletes the IAM role, policy, and all objects in the bucket
before deleting the bucket itself.
To run this script, use the following command:
python delete_resources.py <bucket_name>
"""
import boto3
import os
from dotenv import load_dotenv
from s3_provide_with_roles import check_s3_bucket_exists


# Delete the IAM policy from the role
def delete_s3_bucket_policy(role_name: str, policy_name: str, iam_client: boto3.client) -> None:
    """Deletes an IAM policy from an IAM role."""
    try:
        iam_client.delete_role_policy(
            RoleName=role_name,
            PolicyName=policy_name
        )
        print(f"Policy '{policy_name}' deleted from role '{role_name}'.")
    except iam_client.exceptions.NoSuchEntityException:
        print(f"Policy '{policy_name}' does not exist for role '{role_name}'.")


# Delete the IAM role
def delete_s3_bucket_role(role_name: str, iam_client: boto3.client) -> None:
    """Deletes an IAM role."""
    try:
        iam_client.delete_role(RoleName=role_name)
        print(f"Role '{role_name}' deleted.")
    except iam_client.exceptions.NoSuchEntityException:
        print(f"Role '{role_name}' does not exist.")
    except iam_client.exceptions.DeleteConflictException:
        print(f"Role '{role_name}' cannot be deleted because it still has attached policies.")


# Delete all objects in the bucket before deleting the bucket
def delete_s3_bucket_contents(bucket_name: str, s3_client: boto3.client) -> None:
    """Deletes all objects in an S3 bucket."""
    try:
        objects = s3_client.list_objects_v2(Bucket=bucket_name)
        if 'Contents' in objects:
            for obj in objects['Contents']:
                s3_client.delete_object(Bucket=bucket_name, Key=obj['Key'])
        print(f"All objects deleted from bucket '{bucket_name}'.")
    except s3_client.exceptions.NoSuchBucket:
        print(f"Bucket '{bucket_name}' does not exist.")
    except Exception as e:
        print(f"Error deleting objects from bucket '{bucket_name}': {e}")


# Delete the S3 bucket
def delete_s3_bucket(bucket_name: str, s3_client: boto3.client) -> None:
    """Deletes an S3 bucket and all objects in it."""
    try:
        delete_s3_bucket_contents(bucket_name, s3_client)
        s3_client.delete_bucket(Bucket=bucket_name)
        print(f"Bucket '{bucket_name}' deleted.")
    except s3_client.exceptions.NoSuchBucket:
        print(f"Bucket '{bucket_name}' does not exist.")
    except Exception as e:
        print(f"Error deleting bucket '{bucket_name}': {e}")


def main() -> None:
    """
    Main entry point for the script.

    This script deletes the IAM role, policy, and all objects in the bucket
    before deleting the bucket itself.
    
    AWS services involved:
    - S3: For creating and managing buckets.
    - IAM: For managing roles and instance profiles.
    """
    load_dotenv(dotenv_path='../../.env/sandbox_env')
    bucket_name= os.environ.get('BUCKET_NAME')
    region = os.environ.get('BUCKET_REGION')
    role_name = os.environ.get('BUCKET_ROLE_NAME')
    policy_name = os.environ.get('BUCKET_POLICY_NAME')

    # Initiate the S3 and IAM clients
    s3_client = boto3.client('s3', region_name=region)
    iam_client = boto3.client('iam')

    # Remove all resources
    delete_s3_bucket_policy(role_name, policy_name, iam_client)
    delete_s3_bucket_role(role_name, iam_client)
    if check_s3_bucket_exists(bucket_name, s3_client):
        delete_s3_bucket(bucket_name, s3_client)
    else:
        print(f"Bucket '{bucket_name}' does not exist.")

    print("--- The script has completed. ---")    


if __name__ == "__main__":
    main()