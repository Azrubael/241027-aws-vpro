#!/bin/bash

BUCKET_NAME=$1
REGION="us-east-1"

# Check if the bucket name is provided
if [ -z "$BUCKET_NAME" ]; then
    echo "Error: Bucket name is required."
    echo "Usage: $0 <bucket-name>"
    exit 1
fi

# Delete the S3 bucket
aws s3api delete-bucket --bucket $BUCKET_NAME --region $REGION

# Check if the deletion was successful
if [ $? -eq 0 ]; then
    echo "Bucket $BUCKET_NAME successfully deleted in region $REGION."
else
    echo "Failed to delete bucket $BUCKET_NAME in region $REGION. Please check for errors."
fi
