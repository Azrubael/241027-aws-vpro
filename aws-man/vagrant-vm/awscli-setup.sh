#!/bin/bash

echo
echo "### [20] Update Unbuntu before installation AWS CLI."
sudo apt-get update


echo
echo "### [21] Download AWS CLI packages."
mkdir /tmp/aws-installialion-files
cd /tmp/aws-installialion-files
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"


echo
echo "### [23] Installation AWS CLI version 2."
unzip awscliv2.zip
sudo ./aws/install


echo
if aws --version; then
    echo "AWS CLI installed successfully."
else
    echo "Something went wrong."
    exit 1
fi


echo
echo "### [24] Setup AWS..."
source /home/vagrant/.env/env_local
mkdir -p /home/vagrant/.aws

# Write the credentials to the credentials file
cat <<EOL > ~/.aws/credentials
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
EOL

# Write the configuration to the config file
cat <<EOL > ~/.aws/config
[default]
region = $AWS_DEFAULT_REGION
output = $AWS_OUTPUT_FORMAT
EOL

rm -f /home/vagrant/.env/env_local

if aws s3 ls; then
    echo "AWS CLI has been configured successfully!"
else
    echo "Something went wrong."
    exit 1
fi


: << 'AWSCLI_MANUAL_CONFIG'
aws configure
aws s3 ls
AWSCLI_MANUAL_CONFIG
