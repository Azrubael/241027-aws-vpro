# The Python3 script to create an AWS EC2 launch template
# for TomCat autoscaling group

import os
import boto3
import base64
import json


def create_ec2_launch_template():
    from dotenv import load_dotenv

    load_dotenv('../../.env/sandbox_env')

    BUCKET_NAME = os.environ.get('BUCKET_NAME')
    OS_IMAGE_ID = os.environ.get('OS_IMAGE_ID', "ami-0ddc798b3f1a5117e")
    FRONTEND_SG = os.environ.get('FRONTEND_SG')
    INSTANCE_PROFILE_NAME = os.environ.get('INSTANCE_PROFILE_NAME')
    FRONTEND_SUBNET_NAME = os.environ.get('FRONTEND_NAME')
    BUCKET_REGION = os.environ.get('BUCKET_REGION')

    # Initialize a session using Boto3
    ec2_client = boto3.client('ec2', region_name=BUCKET_REGION)

    # Get IDs of frontend subnet and security group
    subnet_id = get_subnet_id(ec2_client, FRONTEND_SUBNET_NAME)
    frontend_sg_id = get_security_group_id(ec2_client, FRONTEND_SG)

    # User data script
    user_data_script = f"""#!/bin/bash
mkdir -p /tmp/provisioning
cd /tmp/provisioning
aws s3 cp s3://{BUCKET_NAME}/aws-vm/4-tomcat.sh .
aws s3 cp s3://{BUCKET_NAME}/aws-vm/application.properties .
aws s3 cp s3://{BUCKET_NAME}/artifact/vpro.zip .
aws s3 cp s3://{BUCKET_NAME}/artifact/vpro.z01 .
aws s3 cp s3://{BUCKET_NAME}/artifact/vpro.z02 .
bash 4-tomcat.sh"""

    user_data_encoded = base64.b64encode(user_data_script.encode('utf-8')).decode('utf-8')

    # Create the launch template
    try:
        response = ec2_client.create_launch_template(
            LaunchTemplateName='vpro-app-template',
            LaunchTemplateData={
                'ImageId': OS_IMAGE_ID,
                'InstanceType': 't2.micro',
                'KeyName': 'vpro-key',
                'NetworkInterfaces': [{
                    'SubnetId': subnet_id,
                    'AssociatePublicIpAddress': True,
                    'DeviceIndex': 0,
                    'Groups': [frontend_sg_id]
                }],
                'IamInstanceProfile': {
                    'Name': INSTANCE_PROFILE_NAME
                },
                'UserData': user_data_encoded,
                'TagSpecifications': [{
                    'ResourceType': 'instance',
                    'Tags': [
                        {'Key': 'Name', 'Value': 'app01'},
                        {'Key': 'Server', 'Value': 'TomCat'}
                    ]
                }],
                'MetadataOptions': {
                    'HttpEndpoint': 'enabled',
                    'HttpPutResponseHopLimit': 2,
                    'HttpTokens': 'optional'
                },
                'PrivateDnsNameOptions': {
                    'HostnameType': 'ip-name',
                    'EnableResourceNameDnsARecord': False,
                    'EnableResourceNameDnsAAAARecord': False
                }
            }
        )
        print("Launch Template created successfully.")
        print(json.dumps(response, indent=4))
    except Exception as e:
        print(f"Error creating launch template: {e}")


def get_subnet_id(ec2_client, subnet_name):
    response = ec2_client.describe_subnets(
        Filters=[{'Name': 'tag:Name', 'Values': [subnet_name]}]
    )
    subnets = response['Subnets']
    if subnets:
        return subnets[0]['SubnetId']
    else:
        raise Exception(f"No subnet found with name: {subnet_name}")


def get_security_group_id(ec2_client, security_group_name):
    response = ec2_client.describe_security_groups(
        Filters=[{'Name': 'group-name', 'Values': [security_group_name]}]
    )
    security_groups = response['SecurityGroups']
    if security_groups:
        return security_groups[0]['GroupId']
    else:
        raise Exception(f"No security group found with name: {security_group_name}")


if __name__ == "__main__":
    create_ec2_launch_template()
