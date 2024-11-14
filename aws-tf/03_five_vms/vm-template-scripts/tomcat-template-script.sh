#!/bin/bash
# The script to setup a TomCat server on an Amazon Linux 2 instance
# With java11 artifact provisioning

TOMURL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz"

CUSTOM_IPs="""### custom IPs
${db_ip}	db01
${mc_ip}	mc01
${rmq_ip}	rmq01
###"""

sudo echo $CUSTOM_IPs >> /etc/hosts
mkdir -p /tmp/provisioning
cd /tmp/provisioning
aws s3 cp "s3://${S3_BUCKET_NAME}/aws-vm/application.properties" .
aws s3 cp "s3://${S3_BUCKET_NAME}/artifact/vpro.zip" .
aws s3 cp "s3://${S3_BUCKET_NAME}/artifact/vpro.z01" .
aws s3 cp "s3://${S3_BUCKET_NAME}/artifact/vpro.z02" .

sudo yum makecache
sudo yum install -y java-11-amazon-corretto
sudo amazon-linux-extras install epel -y
sudo yum install p7zip wget -y

wget $TOMURL -O tomcatbin.tar.gz
EXTOUT=`tar xzvf tomcatbin.tar.gz`
TOMDIR=`echo $EXTOUT | cut -d '/' -f1`
useradd --shell /sbin/nologin tomcat
rsync -avzh /tmp/provisioning/$TOMDIR/ /usr/local/tomcat/
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

sudo systemctl daemon-reload
sudo systemctl start tomcat
sleep 5

sudo systemctl stop tomcat
sleep 5

sudo rm -rf /usr/local/tomcat/webapps/ROOT*
cd /tmp/provisioning
sudo 7za x vpro.zip
sudo cp vpro-v2.war /usr/local/tomcat/webapps/ROOT.war
sudo cp -f /tmp/provisioning/application.properties /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/application.properties
sudo systemctl start tomcat
sudo systemctl enable tomcat