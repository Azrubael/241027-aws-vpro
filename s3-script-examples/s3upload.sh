#!/bin/bash
# The script to upload the predefiles list of files into AWS S3 bucket $1
# The files will be uploaded into the predefined directories

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
        "aws-vm/4-tomcat.sh" )

for FILE in "${FILES[@]}"; do
    FILE_PATH="../$FILE"
    S3_PATH="s3://$BUCKET_NAME/$FILE"
    if [ -f "$FILE_PATH" ]; then
        echo "Uploading $FILE_PATH to $S3_PATH"
        aws s3 cp "$FILE_PATH" "$S3_PATH"
        
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

