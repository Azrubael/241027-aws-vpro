#!/bin/bash
sudo yum update -y
sudo yum install epel-release -y
sudo yum install wget -y

sudo echo "## vagrant-hostmanager-start
192.168.56.11	web01
192.168.56.12	app01
192.168.56.14	mc01
192.168.56.15	db01
192.168.56.16	rmq01
## vagrant-hostmanager-end" >> /etc/hosts

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
