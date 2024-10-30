#!/bin/bash
# The script to setup a RabbitMQ server on an Amazon Linux 2 instance

sudo yum update -y
sudo yum install epel-release -y
sudo yum install wget -y

sudo echo "### custom IPs
172.19.100.7	db01
172.19.100.8	mc01
172.19.100.9	rmq01
" >> /etc/hosts

cd /tmp/
dnf -y install centos-release-rabbitmq-38
dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
systemctl enable --now rabbitmq-server
firewall-cmd --add-port=5672/tcp
firewall-cmd --runtime-to-permanent
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo systemctl status rabbitmq-server
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo systemctl restart rabbitmq-server
