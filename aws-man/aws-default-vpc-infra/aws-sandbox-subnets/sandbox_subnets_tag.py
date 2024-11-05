#!/usr/bin/env python3
# The script to tag the sanbox subnets in the 'DEFAULT-VPC' network

import os
import boto3
from botocore.exceptions import ClientError
from typing import Optional
from dotenv import load_dotenv


def get_vpc_id_by_tag(tag_name: str, ec2_client: boto3.client) -> Optional[str]:
    """Gets the VPC ID by tag name and returns the ID or None if not found"""
    try:
        response = ec2_client.describe_vpcs(
            Filters=[ { 'Name': 'tag:Name', 'Values': [tag_name] } ]
        )
        vpcs = response.get('Vpcs', [])
        if vpcs:
            return vpcs[0]['VpcId']
        else:
            print("No VPC found with the specified tag.")
            return None
            
    except ClientError as e:
        print(f"Error fetching VPC: {e}")
        return None


def check_vpc_accessibility(vpc_id: str, ec2_client: boto3.client) -> bool:
    """Check if the VPC is accessible"""
    try:
        response = ec2_client.describe_vpcs(VpcIds=[vpc_id])
        if response['Vpcs']:
            print(f"VPC {vpc_id} is accessible.")
            return True
        else:
            print(f"VPC {vpc_id} is not accessible.")
            return False
            
    except ClientError as e:
        print(f"Error checking VPC accessibility: {e}")
        return False


def tag_subnet_if_needed(vpc_id: str, subnet_cidr: str, tag_value: str, ec2_client: boto3.client) -> None:
    """
    Tags a subnet with a specified name if it does not already have a 'Name' tag.

    :param vpc_id: The ID of the VPC containing the subnet.
    :param subnet_cidr: The CIDR block of the subnet to tag.
    :param tag_value: The value to assign to the 'Name' tag.
    :param ec2_client: The boto3 EC2 client used to interact with the AWS EC2 service.
    :return: None
    :raises ClientError: If an error occurs while attempting to describe or tag the subnet.
    """
    subnets = ec2_client.describe_subnets(Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}])
    
    # Find the subnet with the specified CIDR
    for subnet in subnets['Subnets']:
        # Check if the subnet already has the Name tag
        if subnet['CidrBlock'] == subnet_cidr:
            tags = subnet.get('Tags', [])
            name_tag_exists = any(tag['Key'] == 'Name' for tag in tags)
            if not name_tag_exists:
                ec2_client.create_tags(Resources=[subnet['SubnetId']], Tags=[{'Key': 'Name', 'Value': tag_value}])
                print(f"Tagged subnet {subnet['SubnetId']} with Name={tag_value}.")
            else:
                print(f"Subnet {subnet['SubnetId']} already has a Name tag.")
            return

    print(f"No subnet found with CIDR {subnet_cidr} in the {vpc_id}.")


def describe_subnets(vpc_id: str, ec2_client: boto3.client) -> None:
    """Describe subnets for the given VPC ID"""
    try:
        response = ec2_client.describe_subnets(Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}])
    except ClientError as e:
        print(f"Error fetching subnets: {e}")
        return

    subnets_info = []
    for subnet in response['Subnets']:
        subnet_id = subnet['SubnetId']
        cidr_block = subnet['CidrBlock']
        
        # Get the Name tag if it exists
        name_tag = None
        for tag in subnet.get('Tags', []):
            if tag['Key'] == 'Name':
                name_tag = tag['Value']
                break
        
        subnets_info.append({
            'ID': subnet_id,
            'Name': name_tag if name_tag else 'N/A',
            'CIDR': cidr_block
        })

    print(f"{'ID':<25} {'Name':<25} {'CIDR':<20}")
    print("-" * 70)
    for subnet in subnets_info:
        print(f"{subnet['ID']:<25} {subnet['Name']:<25} {subnet['CIDR']:<20}")


if __name__ == "__main__":
    load_dotenv(dotenv_path='./sandbox_env')
    vpc_name = os.getenv('VPC_NAME')
    subnet_cidr = os.getenv('SUBNET_CIDR')
    frontend_cidr = os.getenv('FRONTEND_CIDR')
    frontend_name = os.getenv('FRONTEND_NAME')
    frontend_sg = os.getenv('FRONTEND_SG')
    backend_cidr = os.getenv('BACKEND_CIDR')
    backend_name = os.getenv('BACKEND_NAME')
    backend_sg = os.getenv('BACKEND_SG')

    ec2_client = boto3.client('ec2')
    vpc_id = get_vpc_id_by_tag(vpc_name, ec2_client)
    print()
    
    if vpc_id:
        check_vpc_accessibility(vpc_id, ec2_client)

    tag_subnet_if_needed(vpc_id, frontend_cidr, frontend_name, ec2_client)
    tag_subnet_if_needed(vpc_id, backend_cidr, backend_name, ec2_client)
    
    print()
    describe_subnets(vpc_id, ec2_client)
