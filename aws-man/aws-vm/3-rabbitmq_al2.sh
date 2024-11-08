#!/bin/bash
# The script to setup a RabbitMQ server on an Amazon Linux 2 instance

sudo yum makecache
sudo amazon-linux-extras install epel -y
sudo yum install git -y
sudo yum install -y gcc gcc-c++ make ncurses-devel openssl-devel autoconf


sudo echo "### custom IPs
172.19.100.7	db01
172.19.100.8	mc01
172.19.100.9	rmq01
" >> /etc/hosts

mkdir -p /tmp/provisioning
cd /tmp/provisioning

# Download RabbitMQ
sudo wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.9.13/rabbitmq-server-3.9.13-1.el8.noarch.rpm

# Download and extract the Erlang source code (adjust the version number as needed):
### https://github.com/erlang/otp
sudo git clone https://github.com/erlang/otp.git
cd /tmp/provisioning/otp
sudo git checkout maint-24    # the stable version 24

# Configure, compile, and install Erlang:
sudo ./configure
sudo make
sudo make install

# To verify that Erlang is installed correctly:
# erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().'

# Install RabbitMQ:
cd /tmp/provisioning
sudo rpm -ivh rabbitmq-server-3.9.13-1.el8.noarch.rpm

sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo rabbitmq-plugins enable rabbitmq_management
# sudo systemctl status rabbitmq-server
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo systemctl restart rabbitmq-server
