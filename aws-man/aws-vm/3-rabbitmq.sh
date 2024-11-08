#!/bin/bash
# Amazon CentOS Stream 9 (x86_64)
# https://aws.amazon.com/marketplace/pp/prodview-k66o7o642dfve?ref_=aws-mp-console-subscription-detail
# AMI ID: ami-0df2a11dd1fe1f8e3

sudo yum makecache
sudo yum install epel-release -y

sudo echo "### custom IPs
172.19.100.7	db01
172.19.100.8	mc01
172.19.100.9	rmq01
" >> /etc/hosts

sudo dnf -y install centos-release-rabbitmq-38
sudo dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
sudo systemctl enable --now rabbitmq-server
sudo systemctl start rabbitmq-server
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo systemctl restart rabbitmq-server

: << 'NOTES'
sudo dnf install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --add-port=5672/tcp
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --add-port=22/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --runtime-to-permanent

Configuring SSH to allow access
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/#PermitEmptyPasswords yes/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
sudo sed -i 's/#UsePAM yes/UsePAM yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
NOTES

# Checks
# sudo systemctl status rabbitmq-server
# sudo ss -tuln