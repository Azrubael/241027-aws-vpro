#!/bin/bash
# The script to check if there any AWS S3 buckets

# Set the AWS region (optional, remove if you want to use the default region)
AWS_DEFAULT_REGION="us-east-1"

# List all S3 buckets
echo "Listing all S3 buckets in your AWS account:"
aws s3 ls

echo "==========================================="
echo
# Get more detailed information about each bucket
echo -e "\nDetailed information about each bucket:"
buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

for bucket in $buckets
do
    echo -e "\nBucket: $bucket"
    echo "Creation Date: $(aws s3api list-buckets --query "Buckets[?Name=='$bucket'].CreationDate" --output text)"
    echo "Region: $(aws s3api get-bucket-location --bucket $bucket --query LocationConstraint --output text)"
    
    # Get the number of objects
    num_objects=$(aws s3 ls s3://$bucket --recursive --summarize | grep "Total Objects:" | awk '{print $3}')
    echo "Number of objects: $num_objects"
    
    # Get the total size in bytes
    total_size_bytes=$(aws s3 ls s3://$bucket --recursive --summarize | grep "Total Size:" | awk '{print $3}')
    
    # Convert total size to megabytes
    total_size_mb=$(echo "scale=2; $total_size_bytes / 1048576" | bc)
    echo "Total Size: ${total_size_mb} MB"
    
    echo "-------------------------------------------"
done
