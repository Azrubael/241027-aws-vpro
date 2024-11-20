#!/bin/bash
mkdir -p /tmp/provisioning
cd /tmp/provisioning
aws s3 cp "s3://${S3_BUCKET_NAME}/artifact/mysql_check.py" .

sudo echo -e "### custom IPs
${db_ip}	db01
${mc_ip}	mc01
${rmq_ip}	rmq01
###" >> /etc/hosts

sudo yum makecache
sudo yum install mc -y