#!/usr/bin/env python3
# The script to delete security groups of the sanbox subnets
# in the 'DEFAULT-VPC' network

import os
import boto3
from botocore.exceptions import ClientError
from typing import Optional
from dotenv import load_dotenv
import time


def get_subnet_id_by_name(name: str, ec2_client: boto3.client) -> Optional[str]:
    """Get the subnet ID by its name tag."""
    response = ec2_client.describe_subnets(
        Filters=[{'Name': 'tag:Name', 'Values': [name]}]
    )
    subnets = response['Subnets']
    if subnets:
        return subnets[0]['SubnetId']
    return None


def get_security_group_id_by_name(name: str, ec2_client: boto3.client) -> Optional[str]:
    """Get the security group ID by its name."""
    response = ec2_client.describe_security_groups(
        Filters=[{'Name': 'group-name', 'Values': [name]}]
    )
    security_groups = response['SecurityGroups']
    if security_groups:
        return security_groups[0]['GroupId']
    return None


def delete_security_group(group_id: str, ec2_client: boto3.client) -> None:
    """Delete a security group by its ID."""

    try:
        ec2_client.delete_security_group(GroupId=group_id)
        print(f"Deleted security group: {group_id}")
    except Exception as e:
        print(f"Error deleting security group {group_id}: {e}")


def delete_instance_profile(instance_profile_name: str, iam_client: boto3.client) -> None:
    """
    This function will delete an instance profile by its name.
    Before deleting the instance profile, it will remove all roles
    from the instance profile.

    Parameters:
    instance_profile_name (str): The name of the instance profile to delete.
    iam_client (boto3.client): The IAM client to use for the delete operation.

    Returns:
    None
    """
    try:
        # Check if the instance profile exists
        response = iam_client.get_instance_profile(InstanceProfileName=instance_profile_name)
        print(f"Instance profile '{instance_profile_name}' found. Proceeding to delete.")
        
        # Delete the instance profile
        iam_client.delete_instance_profile(InstanceProfileName=instance_profile_name)
        print(f"Instance profile '{instance_profile_name}' deleted successfully.")

        # Remove all roles from the instance profile
        roles = response['InstanceProfile']['Roles']
        for role in roles:
            iam_client.remove_role_from_instance_profile(
                InstanceProfileName=instance_profile_name,
                RoleName=role['RoleName']
            )
            print(f"Removed role '{role['RoleName']}' from instance profile '{instance_profile_name}'.")

    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchEntity':
            print(f"Instance profile '{instance_profile_name}' does not exist.")
        else:
            print(f"Error: {e}")


if __name__ == "__main__":
    load_dotenv(dotenv_path='./sandbox_env')
    frontend_name = os.getenv('FRONTEND_NAME')
    frontend_sg = os.getenv('FRONTEND_SG')
    backend_name = os.getenv('BACKEND_NAME')
    backend_sg = os.getenv('BACKEND_SG')

    ec2_client = boto3.client('ec2')

    frontend_id = get_subnet_id_by_name(frontend_name, ec2_client)
    print(f"Found {frontend_name} with ID: {frontend_id}. This is the default subnet for the 'DEFAULT-VPC' network.")
    backend_id = get_subnet_id_by_name(backend_name, ec2_client)
    print(f"Found {backend_name} with ID: {backend_id}. This is the default subnet for the 'DEFAULT-VPC' network.")

    frontend_sg_id = get_security_group_id_by_name(frontend_sg, ec2_client)
    print(f"Found {frontend_sg_id} with ID: {frontend_sg_id}")
    backend_sg_id = get_security_group_id_by_name(backend_sg, ec2_client)
    print(f"Found {backend_sg_id} with ID: {backend_sg_id}")

    delay = 15
    print(f"Waiting {delay} seconds before deleting security groups...")
    time.sleep(delay)

    if frontend_sg_id:
        delete_security_group(frontend_sg_id, ec2_client)
        print(f"Deleted {frontend_name} security group with ID: {frontend_sg_id}")

    if backend_sg_id:
        delete_security_group(backend_sg_id, ec2_client)
        print(f"Deleted {backend_name} security group with ID: {backend_sg_id}")

    instance_profile_name = os.environ.get('INSTANCE_PROFILE_NAME')
    iam_client = boto3.client('iam')
    delete_instance_profile(instance_profile_name, iam_client)

    print("--- The script has completed. ---")