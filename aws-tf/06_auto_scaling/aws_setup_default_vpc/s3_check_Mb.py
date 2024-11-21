import os
import boto3
from dotenv import load_dotenv

# The Python3 script to check if there any AWS S3 buckets


load_dotenv(dotenv_path='../../.env/sandbox_env')
aws_region = os.getenv('BUCKET_REGION')

# Initialize a session using the specified region
session = boto3.Session(region_name=aws_region)
s3_client = session.client('s3')

def list_s3_buckets():
    print("Listing all S3 buckets in your AWS account:")
    response = s3_client.list_buckets()
    buckets = response['Buckets']
    
    if not buckets:
        print("No S3 buckets found.")
        return
    
    print("===========================================")
    print("\nDetailed information about each bucket:")
    
    for bucket in buckets:
        bucket_name = bucket['Name']
        creation_date = bucket['CreationDate']
        print(f"\nBucket: {bucket_name}")
        print(f"Creation Date: {creation_date}")

        # Get bucket location
        location = s3_client.get_bucket_location(Bucket=bucket_name)
        region = location['LocationConstraint'] if location['LocationConstraint'] else 'us-east-1'
        print(f"Region: {region}")

        # Get number of objects and total size
        num_objects = 0
        total_size_bytes = 0

        # List objects in the bucket
        paginator = s3_client.get_paginator('list_objects_v2')
        for page in paginator.paginate(Bucket=bucket_name):
            if 'Contents' in page:
                for obj in page['Contents']:
                    num_objects += 1
                    total_size_bytes += obj['Size']

        print(f"Number of objects: {num_objects}")
        total_size_mb = total_size_bytes / (1024 * 1024)  # Convert bytes to MB
        print(f"Total Size: {total_size_mb:.2f} MB")
        print("-------------------------------------------")

if __name__ == "__main__":
    list_s3_buckets()
