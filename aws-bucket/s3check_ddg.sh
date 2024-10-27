#!/bin/bash

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it and configure your credentials."
    exit 1
fi

# List all S3 buckets
echo "Fetching list of S3 buckets..."
buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

# Check if there are any buckets
if [ -z "$buckets" ]; then
    echo "No S3 buckets found in the current account."
else
    echo "Existing S3 buckets:"
    echo "$buckets"
fi
