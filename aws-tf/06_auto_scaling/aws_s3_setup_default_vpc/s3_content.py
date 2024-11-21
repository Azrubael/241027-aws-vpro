import sys
import boto3

# The Python3 script to check the content of the AWS S3 bucket $1


def list_s3_bucket_contents(bucket_name):
    s3_client = boto3.client('s3')

    print(f"\n### Listing contents of S3 bucket: {bucket_name}")

    try:
        # List objects in the specified S3 bucket
        paginator = s3_client.get_paginator('list_objects_v2')
        response_iterator = paginator.paginate(Bucket=bucket_name)

        # Check if the bucket is empty
        bucket_empty = True
        for response in response_iterator:
            if 'Contents' in response:
                bucket_empty = False
                for obj in response['Contents']:
                    print(f"{obj['Key']} (Size: {obj['Size']} bytes)")

        if bucket_empty:
            print("The bucket is empty.")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    # Check if the bucket name is provided
    if len(sys.argv) != 2:
        print("Error: S3 bucket name is required.")
        print("Usage: python check_s3_bucket_content.py <bucket-name>")
        sys.exit(1)

    bucket_name = sys.argv[1]
    list_s3_bucket_contents(bucket_name)
