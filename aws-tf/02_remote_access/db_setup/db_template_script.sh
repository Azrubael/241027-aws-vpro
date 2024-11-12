#!/bin/bash
mkdir -p /tmp/provisioning
cd /tmp/provisioning
aws s3 cp s3://${bucket_name}/${setup_file} .
aws s3 cp s3://${bucket_name}/${env_file} .
bash ${setup_file}

