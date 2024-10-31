#!/usr/bin/env python3
# The script to create security groups for the sanbox subnets
# in the 'DEFAULT-VPC' network

import os
import boto3
from botocore.exceptions import ClientError
from dotenv import load_dotenv
from sanbox_subnets_tag import get_vpc_id_by_tag

load_dotenv(dotenv_path='subnets_env')


def create_security_group(group_name, description, vpc_id):
    """
    Creates a security group in a specified VPC.

    :param group_name: The name of the security group.
    :param description: A description for the security group.
    :param vpc_id: The ID of the VPC where the security group will be created.
    :return: The ID of the created security group if successful, None otherwise.
    """
    ec2 = boto3.client('ec2')

    try:
        # Create the security group
        response = ec2.create_security_group(
            GroupName=group_name,
            Description=description,
            VpcId=vpc_id
        )
        print(f"\nThe Security Group {group_name} was created with ID: {response['GroupId']}")
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


def authorize_security_group_ingress(group_id, protocol, port, cidr):
    """
    Authorizes ingress rules for a specified security group.

    :param group_id: The ID of the security group.
    :param protocol: The protocol for the rule (e.g., 'tcp').
    :param port: The port number for the rule (e.g., 22).
    :param cidr: The CIDR block for the rule (e.g., '0.0.0.0/0').
    """
    session = boto3.Session()
    ec2 = session.client('ec2')

    try:
        port_int=convert_port_to_int(port)
        response = ec2.authorize_security_group_ingress(
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


if __name__ == "__main__":
    wan = "0.0.0.0/0"
    vpc_name = os.getenv('VPC_NAME')
    subnet_cidr = os.getenv('SUBNET_CIDR')

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

    vpc_id = get_vpc_id_by_tag(vpc_name)

    frontend_sg_id = create_security_group(frontend_sg, fsg_note, vpc_id)
    for rule in frontend_rules:
        authorize_security_group_ingress(frontend_sg_id, rule['protocol'], rule['port'], wan)


    backend_sg_id = create_security_group(backend_sg, bsg_note, vpc_id)
    for rule in backend_rules:
        authorize_security_group_ingress(backend_sg_id, rule['protocol'], rule['port'], frontend_cidr)



