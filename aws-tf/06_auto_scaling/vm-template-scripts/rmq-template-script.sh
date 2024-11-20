#!/bin/bash
# The script to setup a RabbitMQ server on Amazon CentOS Stream 9 (x86_64)
# https://aws.amazon.com/marketplace/pp/prodview-k66o7o642dfve?ref_=aws-mp-console-subscription-detail
# AMI ID: ami-0df2a11dd1fe1f8e3

sudo yum makecache
sudo yum install epel-release -y

sudo echo -e "### custom IPs
${db_ip}	db01
${mc_ip}	mc01
${rmq_ip}	rmq01
###" >> /etc/hosts

sudo dnf -y install centos-release-rabbitmq-38
sudo dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
sudo systemctl enable --now rabbitmq-server
sudo systemctl start rabbitmq-server
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo systemctl restart rabbitmq-server

# Checks
# sudo systemctl status rabbitmq-server
# sudo ss -tuln