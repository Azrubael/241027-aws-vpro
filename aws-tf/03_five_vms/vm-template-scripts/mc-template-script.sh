#!/bin/bash
# The script to setup a MemcacheD server on an Amazon Linux 2 instance

sudo yum makecache
sudo amazon-linux-extras install epel -y
sudo yum install memcached -y

CUSTOM_IPs="""### custom IPs
${db_ip}	db01
${mc_ip}	mc01
${rmq_ip}	rmq01
###"""

sudo echo $CUSTOM_IPs >> /etc/hosts

sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl status memcached

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached
sudo memcached -p 11211 -U 11111 -u memcached -d