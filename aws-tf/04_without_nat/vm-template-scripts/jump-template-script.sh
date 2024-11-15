#!/bin/bash
mkdir -p /tmp/provisioning
cd /tmp/provisioning

CUSTOM_IPs="""### custom IPs
${db_ip}	db01
${mc_ip}	mc01
${rmq_ip}	rmq01
###"""

sudo echo $CUSTOM_IPs >> /etc/hosts

sudo yum makecache
sudo yum install mc git -y