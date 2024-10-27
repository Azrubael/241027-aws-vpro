#!/bin/bash

# Set your desired bucket name
BUCKET_NAME="az-$(date +%Y%m%d)"

# Create the S3 bucket in us-east-1 region
aws s3api create-bucket --bucket $BUCKET_NAME --region us-east-1

# Verify the bucket was created
if aws s3api head-bucket --bucket $BUCKET_NAME; then
    echo "Bucket $BUCKET_NAME created successfully in us-east-1 region."
esle
    echo "Something went wrong."
fi
