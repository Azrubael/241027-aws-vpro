#!/bin/bash
mkdir -p /tmp/provisioning
cd /tmp/provisioning
aws s3 cp s3://${bucket_name}/${setup_file} .
bash ${setup_file}

