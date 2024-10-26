# adding repository and installing nginx		
apt-get update -y
apt-get install nginx -y
# apt-get install mc -y

sudo echo "## vagrant-hostmanager-start
192.168.56.11	web01
192.168.56.12	app01
192.168.56.14	mc01
192.168.56.15	db01
192.168.56.16	rmq01
## vagrant-hostmanager-end" >> /etc/hosts

cat <<EOT > vproapp
upstream vproapp {
 server app01:8080;
}
server {
  listen 80;
location / {
  proxy_pass http://vproapp;
  }
}
EOT

mv vproapp /etc/nginx/sites-available/vproapp
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

#starting nginx service
systemctl start nginx
systemctl enable nginx
systemctl restart nginx
