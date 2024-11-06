#!/bin/bash
# The script to setup a MemcacheD server on an Amazon Linux 2 instance

sudo yum update -y
sudo amazon-linux-extras install epel -y
sudo yum install memcached -y

sudo echo "### custom IPs
172.19.100.7	db01
172.19.100.8	mc01
172.19.100.9	rmq01
" >> /etc/hosts

sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl status memcached

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached
sudo memcached -p 11211 -U 11111 -u memcached -d
