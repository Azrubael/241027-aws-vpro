#!/bin/bash
mkdir -p /tmp/provisioning
cd /tmp/provisioning

sudo yum makecache
sudo yum install mc git -y