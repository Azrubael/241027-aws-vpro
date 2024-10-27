#!/bin/bash
sudo dnf install epel-release -y
sudo dnf install memcached -y

sudo echo "## vagrant-hostmanager-start
192.168.56.11	web01
192.168.56.12	app01
192.168.56.14	mc01
192.168.56.15	db01
192.168.56.16	rmq01
## vagrant-hostmanager-end" >> /etc/hosts

sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl status memcached

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached
sudo memcached -p 11211 -U 11111 -u memcached -d
