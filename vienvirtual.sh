#!/bin/bash

if [ "$(whoami)" != 'root' ]; then
  echo "Maaf, Anda harus menjalankan ini sebagai root !!!"
  exit 1
fi

DISTRO=$(cat /etc/*-release | grep -w NAME | cut -d= -f2 | tr -d '"')
#CentOS Linux
#Ubuntu

if [ "$DISTRO" != 'CentOS Linux' ]; then
  echo "Maaf !!! OS Anda Bukan Centos"
  exit 1
fi

read -p "Masukkan Domain Anda: " domain_name
if ! [[ "$domain_name" =~ (^([a-zA-Z0-9](([a-zA-Z0-9-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$) ]]; then
  echo "$domain_name is a not a correct domain name"
  exit 1
fi
echo $domain_name
sudo yum -y update httpd
sudo yum -y install httpd

#add port 80 and 443 in firewall
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

#start apache service
sudo systemctl restart httpd

#check is apache running in server
if ! pidof httpd >/dev/null; then
  echo 'Apache Tidak Berjalan !!!'
  exit 1
fi

#create domain required folder and files
sudo mkdir -p /var/www/$domain_name/public_html
sudo mkdir -p /var/www/$domain_name/log
sudo chown -R apache:apache /var/www/$domain_name/public_html
# sudo chown -R $USER:$USER /var/www/$domain_name/public_html
sudo chmod -R 755 /var/www/$domain_name
echo "<?php phpinfo(INFO_MODULES); ?>" > /var/www/$domain_name/public_html/index.php

sudo mkdir -p /etc/httpd/sites-available /etc/httpd/sites-enabled

#check if site enabled not added in conf file. then add it in conf file
if ! grep -Fxq "IncludeOptional sites-enabled/*.conf" /etc/httpd/conf/httpd.conf; then
  echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
fi

#virtual host file
echo "<VirtualHost *:80>
    ServerName $domain_name
    ServerAlias $domain_name
    DocumentRoot /var/www/$domain_name/public_html
    ErrorLog /var/www/$domain_name/log/error.log
    CustomLog /var/www/$domain_name/log/requests.log combined
</VirtualHost>" > /etc/httpd/sites-available/$domain_name.conf

sudo ln -s /etc/httpd/sites-available/$domain_name.conf /etc/httpd/sites-enabled/$domain_name.conf

#recommended apache policy for SE linux
sudo setsebool -P httpd_unified 1

#apache to log and append the file
sudo semanage fcontext -a -t httpd_log_t "/var/www/$domain_name/log(/.*)?"
sudo restorecon -R -v /var/www/$domain_name/log

#restart apache
sudo systemctl restart httpd

if pidof httpd >/dev/null; then
  echo 'Virtual Host Berhasil Di Buat'
  echo 'Silahkan Kunjungi http://'$domain_name
else
  echo 'Apache restart gagal !!!'
  exit 1
fi
