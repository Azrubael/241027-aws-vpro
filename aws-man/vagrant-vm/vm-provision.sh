#!/bin/bash

set -e

echo
echo "### [01] Updating the package list and other preparations"
sudo apt-get update
update-alternatives --set editor /usr/bin/vim.basic
sudo timedatectl set-timezone Europe/Kyiv

###### Increase bash history
cp /home/vagrant/.bashrc /home/vagrant/.bashrc_backup
sed -i 's/^HISTSIZE=.*/HISTSIZE=20000/' /home/vagrant/.bashrc
sed -i 's/^HISTFILESIZE=.*/HISTFILESIZE=20000/' /home/vagrant/.bashrc

####### Create a key which can be used for ssh login
ssh-keygen -N "" -f /home/vagrant/.ssh/az_rsa


echo
echo "### [02] Installing the necessary packages for adding a new repository over HTTPS"
sudo apt-get update
sudo apt-get install mc graphviz -y
sudo apt-get install apt-transport-https ca-certificates gnupg -y


echo
echo "### [03] Installing Terraform"
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update
sudo apt-get install terraform -y

if terraform version &> /dev/null; then
    echo
    echo "###  [04] Terraform installed!"
else
    echo "---------- Terraform doesn't work! ----------"
    exit 1
fi


echo
echo "### [05] Installing Docker Engine"
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

if docker version &> /dev/null; then
    echo
    echo "###  [06] Docker installed!"
    sudo usermod -aG docker vagrant
else
    echo "---------- Docker doesn't work! ----------"
    exit 1
fi