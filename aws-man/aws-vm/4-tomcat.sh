#!/bin/bash
# The script to setup a TomCat server on an Amazon Linux 2 instance
# With java11 artifact provisioning

TOMURL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz"
S3_URL="https://az-20241029.s3.us-east-1.amazonaws.com"

sudo yum install -y java-11-amazon-corretto-jre
sudo yum install p7zip maven wget -y

sudo echo "### custom IPs
172.19.100.7	db01
172.19.100.8	mc01
172.19.100.9	rmq01
" >> /etc/hosts

mkdir -p /tmp/provisioning
cd /tmp/provisioning

wget $TOMURL -O tomcatbin.tar.gz
EXTOUT=`tar xzvf tomcatbin.tar.gz`
TOMDIR=`echo $EXTOUT | cut -d '/' -f1`
useradd --shell /sbin/nologin tomcat
rsync -avzh /tmp/$TOMDIR/ /usr/local/tomcat/
chown -R tomcat.tomcat /usr/local/tomcat
rm -rf /etc/systemd/system/tomcat.service

cat <<EOT >> /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
Group=tomcat
WorkingDirectory=/usr/local/tomcat

Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre

Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINE_BASE=/usr/local/tomcat

ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
SyslogIdentifier=tomcat-%i


RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl start tomcat
sleep 5

wget "${S3_URL}/application.properties"
wget "${S3_URL}/artifact.zip"
wget "${S3_URL}/artifact.z01"
wget "${S3_URL}/artifact.z02"
7z x artifact.zip

systemctl stop tomcat
sleep 5

sudo rm -rf /usr/local/tomcat/webapps/ROOT*
sudo cp /tmp/provisioning/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
sudo cp -f /tmp/provisioning/application.properties /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/application.properties
sudo systemctl start tomcat
sudo systemctl enable tomcat
sleep 5
echo "Setup finished."

: <<'DIAGNISTICS'
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
mvn install
sudo find / -type d -name "vprofile-project"
ss -tuln
DIAGNISTICS