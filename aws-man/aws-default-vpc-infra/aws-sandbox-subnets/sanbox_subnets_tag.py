#!/usr/bin/env python3
# The script to TAG the sanbox subnets in the 'DEFAULT-VPC' network

import boto3
from botocore.exceptions import ClientError
from dotenv import load_dotenv
import os

load_dotenv(dotenv_path='sandbox_env')

def get_vpc_id_by_tag(tag_name):
    """Gets the VPC ID by tag name and returns the ID or None if not found"""
    ec2 = boto3.client('ec2')
    
    try:
        response = ec2.describe_vpcs(
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


def check_vpc_accessibility(vpc_id):
    """Check if the VPC is accessible"""
    ec2 = boto3.client('ec2')
    
    try:
        response = ec2.describe_vpcs(VpcIds=[vpc_id])
        if response['Vpcs']:
            print(f"VPC {vpc_id} is accessible.")
            return True
        else:
            print(f"VPC {vpc_id} is not accessible.")
            return False
            
    except ClientError as e:
        print(f"Error checking VPC accessibility: {e}")
        return False


def tag_subnet_if_needed(vpc_id, subnet_cidr, tag_value):
    ec2 = boto3.client('ec2')

    subnets = ec2.describe_subnets(Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}])
    
    # Find the subnet with the specified CIDR
    for subnet in subnets['Subnets']:
        # Check if the subnet already has the Name tag
        if subnet['CidrBlock'] == subnet_cidr:
            tags = subnet.get('Tags', [])
            name_tag_exists = any(tag['Key'] == 'Name' for tag in tags)
            if not name_tag_exists:
                ec2.create_tags(Resources=[subnet['SubnetId']], Tags=[{'Key': 'Name', 'Value': tag_value}])
                print(f"Tagged subnet {subnet['SubnetId']} with Name={tag_value}.")
            else:
                print(f"Subnet {subnet['SubnetId']} already has a Name tag.")
            return

    print(f"No subnet found with CIDR {subnet_cidr} in the {vpc_id}.")


def describe_subnets(vpc_id):
    """Describe subnets for the given VPC ID"""
    ec2 = boto3.client('ec2')
    try:
        response = ec2.describe_subnets(Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}])
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
    print("=" * 70)
    for subnet in subnets_info:
        print(f"{subnet['ID']:<25} {subnet['Name']:<25} {subnet['CIDR']:<20}")


if __name__ == "__main__":

    vpc_name = os.getenv('VPC_NAME')
    subnet_cidr = os.getenv('SUBNET_CIDR')
    frontend_cidr = os.getenv('FRONTEND_CIDR')
    frontend_name = os.getenv('FRONTEND_NAME')
    frontend_sg = os.getenv('FRONTEND_SG')
    backend_cidr = os.getenv('BACKEND_CIDR')
    backend_name = os.getenv('BACKEND_NAME')
    backend_sg = os.getenv('BACKEND_SG')

    vpc_id = get_vpc_id_by_tag(vpc_name)
    print()
    
    if vpc_id:
        check_vpc_accessibility(vpc_id)

    tag_subnet_if_needed(vpc_id, frontend_cidr, frontend_name)
    tag_subnet_if_needed(vpc_id, backend_cidr, backend_name)
    
    print()
    describe_subnets(vpc_id)
