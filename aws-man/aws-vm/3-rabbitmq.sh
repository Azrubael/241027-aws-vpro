#!/bin/bash
# The script to setup a RabbitMQ server on an Amazon Linux 2 instance

sudo amazon-linux-extras install epel -y
sudo yum install erlang -y

sudo echo "### custom IPs
172.19.100.7	db01
172.19.100.8	mc01
172.19.100.9	rmq01
" >> /etc/hosts

# Create a new repository file for RabbitMQ: 
sudo tee /etc/yum.repos.d/rabbitmq.repo <<EOF
[rabbitmq]
name=RabbitMQ
baseurl=https://dl.bintray.com/rabbitmq/rpm/erlang/24/el/7/x86_64/
gpgcheck=0
enabled=1
EOF

cd /tmp/
sudo yum install rabbitmq-server -y
sudo rabbitmq-plugins enable rabbitmq_management
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
# sudo systemctl status rabbitmq-server
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo systemctl restart rabbitmq-server
