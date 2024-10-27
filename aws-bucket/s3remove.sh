#!/bin/bash

BUCKET_NAME=$1
REGION="us-east-1"

# Delete the S3 bucket
aws s3api delete-bucket --bucket $BUCKET_NAME --region $REGION

# Check if the deletion was successful
if [ $? -eq 0 ]; then
    echo "Bucket $BUCKET_NAME successfully deleted in region $REGION."
else
    echo "Failed to delete bucket $BUCKET_NAME in region $REGION. Please check for errors."
fi
