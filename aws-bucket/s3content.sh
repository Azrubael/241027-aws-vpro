#!/bin/bash
# The script to check the content of the AWS S3 bucket $1

# Check if the bucket name is provided
if [ -z "$1" ]; then
    echo "Error: S3 bucket name is required."
    echo "Usage: $0 <bucket-name>"
    exit 1
fi

BUCKET_NAME=$1

echo
echo "### Listing contents of S3 bucket: $BUCKET_NAME"
aws s3 ls "s3://$BUCKET_NAME/"