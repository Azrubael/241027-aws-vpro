#!/usr/bin/env python3
# The script to delete security groups of the sanbox subnets
# in the 'DEFAULT-VPC' network

import os
import boto3
from dotenv import load_dotenv
import time

load_dotenv(dotenv_path='./sandbox_env')


def get_subnet_id_by_name(name):
    """Get the subnet ID by its name tag."""
    ec2 = boto3.client('ec2')
    response = ec2.describe_subnets(
        Filters=[{'Name': 'tag:Name', 'Values': [name]}]
    )
    subnets = response['Subnets']
    if subnets:
        return subnets[0]['SubnetId']
    return None


def get_security_group_id_by_name(name):
    """Get the security group ID by its name."""
    ec2 = boto3.client('ec2')
    response = ec2.describe_security_groups(
        Filters=[{'Name': 'group-name', 'Values': [name]}]
    )
    security_groups = response['SecurityGroups']
    if security_groups:
        return security_groups[0]['GroupId']
    return None


def delete_security_group(group_id):
    """Delete a security group by its ID."""
    ec2 = boto3.client('ec2')
    try:
        ec2.delete_security_group(GroupId=group_id)
        print(f"Deleted security group: {group_id}")
    except Exception as e:
        print(f"Error deleting security group {group_id}: {e}")



if __name__ == "__main__":
    frontend_name = os.getenv('FRONTEND_NAME')
    frontend_sg = os.getenv('FRONTEND_SG')
    backend_name = os.getenv('BACKEND_NAME')
    backend_sg = os.getenv('BACKEND_SG')

    frontend_id = get_subnet_id_by_name(frontend_name)
    # print(f"{frontend_name} has ID: {frontend_id}")
    backend_id = get_subnet_id_by_name(backend_name)
    # print(f"{backend_name} has ID: {backend_id}")

    frontend_sg_id = get_security_group_id_by_name(frontend_sg)
    backend_sg_id = get_security_group_id_by_name(backend_sg)

    time.sleep(10)
    print("Waiting 10 seconds before deleting security groups...")
    
    if frontend_sg_id:
        delete_security_group(frontend_sg_id)
        print(f"Deleted {frontend_name} security group with ID: {frontend_sg_id}")

    if backend_sg_id:
        delete_security_group(backend_sg_id)
        print(f"Deleted {backend_name} security group with ID: {backend_sg_id}")

