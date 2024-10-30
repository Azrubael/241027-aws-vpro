#!/bin/bash
# The script to upload the predefiles list of files into AWS S3 bucket $1
# All files will be uploaded without any structure at root of the S3 bucket

# Check if the bucket name is provided
if [ -z "$1" ]; then
    echo "Error: S3 bucket name is required."
    echo "Usage: $0 <bucket-name>"
    exit 1
fi

BUCKET_NAME=$1

# An array of files to upload
FILES=( "artifact/vpro.zip"
        "artifact/vpro.z01"
        "artifact/vpro.z02"
        "env/db_env"
        "aws-vm/application.properties"
        "aws-vm/1-mysql.sh"
        "aws-vm/2-memcached.sh"
        "aws-vm/3-rabbitmq.sh"
        "aws-vm/4-tomcat.sh"
        "aws-vm/5-nginx.sh" )

for FILE in "${FILES[@]}"; do
    FILEPATH="../../$FILE"
    if [ -f "$FILEPATH" ]; then
        echo "Uploading $FILEPATH to s3://$BUCKET_NAME/"
        aws s3 cp "$FILEPATH" "s3://$BUCKET_NAME/"
        
        # Check if the upload was successful
        if [ $? -eq 0 ]; then
            echo "$FILE successfully uploaded to s3://$BUCKET_NAME/"
        else
            echo "Failed to upload $FILE to s3://$BUCKET_NAME/. Please check for errors."
        fi
    else
        echo "Warning: $FILE doesn't exist and cannot be uploaded."
    fi
done

echo
echo "### Listing contents of S3 bucket: $BUCKET_NAME"
aws s3 ls "s3://$BUCKET_NAME/"

