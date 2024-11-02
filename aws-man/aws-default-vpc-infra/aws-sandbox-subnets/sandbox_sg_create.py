#!/usr/bin/env python3
"""
This script creates security groups for the sanbox subnets
in the 'DEFAULT-VPC' network
"""
import os
import boto3
from botocore.exceptions import ClientError
from dotenv import load_dotenv
from sandbox_subnets_tag import get_vpc_id_by_tag


def create_ec2_security_group(group_name, description, vpc_id, ec2_client):
    """
    Creates a security group in a specified VPC.

    :param group_name: The name of the security group.
    :param description: A description for the security group.
    :param vpc_id: The ID of the VPC where the security group will be created.
    :return: The ID of the created security group if successful, None otherwise.
    """
    try:
        # Create the security group
        response = ec2_client.create_security_group(
            GroupName=group_name,
            Description=description,
            VpcId=vpc_id
        )
        print(f"The Security Group {group_name} was created with ID: {response['GroupId']}\n")
        return response['GroupId']
    except ClientError as e:
        print(f"\nError creating security group: {e}")
        return None


def convert_port_to_int(value):
    """
    Converts a string to an integer, handling exceptions if the conversion fails.

    :param value: The string value to convert.
    :return: The converted integer or None if conversion fails.
    """
    try:
        return int(value)
    except ValueError:
        print(f"Error: '{value}' cannot be converted to an integer.")
        return None
    except TypeError:
        print(f"Error: Invalid type '{type(value).__name__}' provided.")
        return None


def authorize_ec2_security_group_ingress(group_id, protocol, port, cidr, ec2_client):
    """
    Authorizes ingress traffic for a ec2 security group.

    :param group_id: The ID of the security group to modify.
    :param protocol: The protocol to allow. Valid values include 'tcp', 'udp', 'icmp', or None
        to represent all protocols.
    :param port: The port to allow. A single integer or a range (e.g., 1024-2048).
    :param cidr: The CIDR block to allow traffic from.
    :param ec2_client: The boto3 EC2 client used to interact with AWS EC2 service.
    :return: The response from the AWS API if successful, None otherwise.
    :raises ClientError: If an error occurs while attempting to modify the security group.
    """
    try:
        port_int=convert_port_to_int(port)
        response = ec2_client.authorize_security_group_ingress(
            GroupId=group_id,
            IpPermissions=[
                {
                    'IpProtocol': protocol,
                    'FromPort': port_int,
                    'ToPort': port_int,
                    'IpRanges': [{'CidrIp': cidr}]
                }
            ]
        )
        # print("Ingress Successfully Set:", response)
        return response
    except Exception as e:
        print("Error:", e)


def check_aws_sg_exists(sg_name, vpc_id, ec2_client):
    """
    Checks if a security group with the specified name exists in the given VPC.

    :param sg_name: The name of the security group to check.
    :param vpc_id: The ID of the VPC where the security group is expected to be.
    :param ec2_client: The boto3 EC2 client used to interact with AWS EC2 service.
    :return: True if the security group exists, False otherwise.
    :raises ClientError: If an error occurs while attempting to describe security groups.
    """
    try:
        # Describe security groups with the specified filters
        response = ec2_client.describe_security_groups(
            Filters=[
                {'Name': 'group-name', 'Values': [sg_name]},
                {'Name': 'vpc-id', 'Values': [vpc_id]}
            ]
        )
        
        # Check if any security groups were returned
        result = len(response['SecurityGroups']) > 0
        print(f"Security group {sg_name} exists: {result}")
        return result
    
    except ClientError as e:
        # Handle exceptions (e.g., if the VPC ID is invalid)
        print(f"An error occurred: {e}")
        return False


def create_instance_profile_and_add_role(instance_profile_name, role_name, iam_client):
    """
    Creates an instance profile and adds a role to it.

    If the instance profile does not exist, it will be created.
    If the instance profile already exists, the function will exit early.

    :param instance_profile_name: The name of the instance profile to create.
    :param role_name: The name of the role to add to the instance profile.
    :param iam_client: The IAM client to use for the operations.
    :return: None
    """
    try:        # Check if the instance profile already exists
        response = iam_client.get_instance_profile(InstanceProfileName=instance_profile_name)
        if response['InstanceProfile']['Arn']:
            print(f"Instance profile '{instance_profile_name}' already exists.")
        return  # Exit the function if the instance profile exists
    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchEntity':
            print(f"Creating instance profile '{instance_profile_name}'...")
        else:
            print(f"Error checking instance profile: {e}")
            return

    try:        # Create the instance profile
        iam_client.create_instance_profile(InstanceProfileName=instance_profile_name)
        print(f"Instance profile '{instance_profile_name}' created successfully.")
        # Add the role to the instance profile
        iam_client.add_role_to_instance_profile(
            InstanceProfileName=instance_profile_name,
            RoleName=role_name
        )
        print(f"Role '{role_name}' added to instance profile '{instance_profile_name}' successfully.")

    except ClientError as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    wan = "0.0.0.0/0"

    load_dotenv(dotenv_path='./subnets_env')
    vpc_name = os.getenv('VPC_NAME')
    frontend_cidr = os.getenv('FRONTEND_CIDR')
    frontend_name = os.getenv('FRONTEND_NAME')
    frontend_sg = os.getenv('FRONTEND_SG')
    fsg_note = os.getenv('FRONTEND_SG_NOTE')
    frontend_rules = [
        { "protocol" : os.getenv('FRONTEND_PROTOCOL1'),
          "port" : os.getenv('FRONTEND_PORT1') },
        { "protocol" : os.getenv('FRONTEND_PROTOCOL2'),
          "port" : os.getenv('FRONTEND_PORT2') },
        { "protocol" : os.getenv('FRONTEND_PROTOCOL3'),
          "port" : os.getenv('FRONTEND_PORT3') }
    ]
    backend_cidr = os.getenv('BACKEND_CIDR')
    backend_name = os.getenv('BACKEND_NAME')
    backend_sg = os.getenv('BACKEND_SG')
    bsg_note = os.getenv('FRONTEND_SG_NOTE')
    backend_rules = [
        { "protocol" : os.getenv('BACKEND_PROTOCOL1'),
          "port" : os.getenv('BACKEND_PORT1') },
        { "protocol" : os.getenv('BACKEND_PROTOCOL2'),
          "port" : os.getenv('BACKEND_PORT2') },
        { "protocol" : os.getenv('BACKEND_PROTOCOL3'),
          "port" : os.getenv('BACKEND_PORT3') },
        { "protocol" : os.getenv('BACKEND_PROTOCOL4'),
          "port" : os.getenv('BACKEND_PORT4') }
    ]

    load_dotenv(dotenv_path=f'{os.environ.get("HOME")}/.aws/devops_id')
    account_id = os.environ.get('AWSN')
    bucket_name= os.environ.get('BUCKET_NAME')
    region = os.environ.get('BUCKET_REGION')
    role_name = os.environ.get('BUCKET_ROLE_NAME')
    instance_profile_name = os.environ.get('INSTANCE_PROFILE_NAME')

    vpc_id = get_vpc_id_by_tag(vpc_name)
    ec2_client = boto3.client('ec2')

    if not check_aws_sg_exists(frontend_sg, vpc_id, ec2_client):
        frontend_sg_id = create_ec2_security_group(frontend_sg, fsg_note, vpc_id, ec2_client)
        for rule in frontend_rules:
            authorize_ec2_security_group_ingress(frontend_sg_id, rule['protocol'], rule['port'], wan, ec2_client)

    if not check_aws_sg_exists(backend_sg, vpc_id, ec2_client):
        backend_sg_id = create_ec2_security_group(backend_sg, bsg_note, vpc_id, ec2_client)
        for rule in backend_rules:
            authorize_ec2_security_group_ingress(backend_sg_id, rule['protocol'], rule['port'], frontend_cidr, ec2_client)

    # Create the Instance Profile and add the Role to it if it doesn't exist
    create_instance_profile_and_add_role(instance_profile_name, role_name, boto3.client('iam'))

    print("\n+++ The security groups has created +++\n")