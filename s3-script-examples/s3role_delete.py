"""
This script deletes the IAM role, policy, and all objects in the bucket
before deleting the bucket itself.
To run this script, use the following command:
python delete_resources.py <bucket_name>

                !!! WITHOUT handling the policy !!!
"""
import boto3
import sys

# Get bucket name from command line arguments
if len(sys.argv) != 2:
    print("Usage: python delete_resources.py <bucket_name>")
    sys.exit(1)

bucket_name = sys.argv[1]
role_name = "EC2S3AccessRole"
policy_name = "S3AccessPolicy"

# Initiate the S3 and IAM clients
s3_client = boto3.client('s3', region_name='us-east-1')
iam_client = boto3.client('iam')


# Delete all objects in the bucket before deleting the bucket
def delete_bucket_contents(bucket_name):
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


# Delete the IAM policy from the role
def delete_policy(role_name, policy_name):
    try:
        iam_client.delete_role_policy(
            RoleName=role_name,
            PolicyName=policy_name
        )
        print(f"Policy '{policy_name}' deleted from role '{role_name}'.")
    except iam_client.exceptions.NoSuchEntityException:
        print(f"Policy '{policy_name}' does not exist for role '{role_name}'.")


# Delete the IAM role
def delete_role(role_name):
    try:
        iam_client.delete_role(RoleName=role_name)
        print(f"Role '{role_name}' deleted.")
    except iam_client.exceptions.NoSuchEntityException:
        print(f"Role '{role_name}' does not exist.")
    except iam_client.exceptions.DeleteConflictException:
        print(f"Role '{role_name}' cannot be deleted because it still has attached policies.")


# Delete the S3 bucket
def delete_bucket(bucket_name):
    try:
        delete_bucket_contents(bucket_name)
        s3_client.delete_bucket(Bucket=bucket_name)
        print(f"Bucket '{bucket_name}' deleted.")
    except s3_client.exceptions.NoSuchBucket:
        print(f"Bucket '{bucket_name}' does not exist.")
    except Exception as e:
        print(f"Error deleting bucket '{bucket_name}': {e}")


# Remove all resources
delete_policy(role_name, policy_name)
delete_role(role_name)
delete_bucket(bucket_name)