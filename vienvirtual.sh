#!/bin/bash

if [ "$(whoami)" != 'root' ]; then
  echo "Maaf, Anda harus menjalankan ini sebagai root !!!"
  exit 1
fi

DISTRO=$(cat /etc/*-release | grep -w NAME | cut -d= -f2 | tr -d '"')
if [ "$DISTRO" != 'CentOS Linux' ]; then
  echo "Maaf !!! OS Anda Bukan Centos"
  exit 1
fi

SERVICE_="httpd"
VHOST_PATH="/etc/httpd/conf.d"
SSL_PATH="/etc/httpd/vienssl"
CFG_TEST="service httpd configtest"

read -p "Masukkan Domain/SubDomain Tanpa www: " domain_name
if ! [[ "$domain_name" =~ (^([a-zA-Z0-9](([a-zA-Z0-9-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$) ]]; then
  echo "$domain_name Nama Domain Salah !!! Silahkan Jalankan Ulang Scriptnya !!!"
  exit 1
fi

if ! mkdir -p /var/www/$domain_name/public_html; then
  echo "Domain Sudah Ada !!!"
  exit 1
fi

echo "<h1>Domain $domain_name</h1>" >/var/www/$domain_name/public_html/index.php
chown -R apache:apache /var/www/$domain_name/public_html
chmod -R 775 /var/www/$domain_name/public_html
mkdir -p /var/www/$domain_name/log

echo "<VirtualHost *:80>
      ServerName $domain_name
      ServerAlias www.$domain_name
      DocumentRoot /var/www/$domain_name/public_html
      ErrorLog /var/www/$domain_name/log/error.log
      CustomLog /var/www/$domain_name/log/requests.log combined
      <Directory /var/www/$domain_name/public_html>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        Allow from all
        Require all granted
      </Directory>
      </VirtualHost>" > $VHOST_PATH/$domain_name.conf
if ! echo -e $VHOST_PATH/$domain_name.conf; then
  echo "=========================================================="
  echo "Gagal Membuat Virtual Host !!!"
  echo "=========================================================="
  exit 1
else
  echo "=========================================================="
  echo "Berhasil Membuat Virtual Host Dengan Domain $domain_name"
  echo "=========================================================="
fi
echo "Ingin Membuat SSL ? [y/n]? "
read q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
  mkdir -p $SSL_PATH/$domain_name
  yum install -y openssl mod_ssl
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $SSL_PATH/$domain_name/$domain_name.key -out $SSL_PATH/$domain_name/$domain_name.crt
  if ! echo -e $SSL_PATH/$domain_name/$domain_name.key; then
    echo "=========================================================="
    echo "Certificate Key SSL Gagal Dibuat !"
    echo "=========================================================="
  else
    echo "=========================================================="
    echo "Certificate key SSL Berhasil Dibuat !"
    echo "=========================================================="
  fi
  if ! echo -e $SSL_PATH/$domain_name/$domain_name.crt; then
    echo "=========================================================="
    echo "Certificate SSL Gagal Dibuat !"
    echo "=========================================================="
  else
    echo "=========================================================="
    echo "Certificate SSL Berhasil Dibuat !"
    echo "=========================================================="
  fi

  echo "<VirtualHost *:443>
          ServerName $domain_name
          ServerAlias www.$domain_name
          DocumentRoot /var/www/$domain_name/public_html
          ErrorLog /var/www/$domain_name/log/error.log
          CustomLog /var/www/$domain_name/log/requests.log combined
          SSLEngine on
          SSLCertificateFile $SSL_PATH/$domain_name/$domain_name.crt
          SSLCertificateKeyFile $SSL_PATH/$domain_name/$domain_name.key
          <Directory /var/www/$domain_name/public_html>
            Options Indexes FollowSymLinks MultiViews
            AllowOverride All
            Order allow,deny
            Allow from all
            Satisfy Any
          </Directory>
        </VirtualHost>" > $VHOST_PATH/ssl.$domain_name.conf
  if ! echo -e $VHOST_PATH/ssl.$domain_name.conf; then
    echo "=========================================================="
    echo "SSL Virtual Host Gagal Dibuat !"
    echo "=========================================================="
  else
    echo "=========================================================="
    echo "SSL Virtual Host Berhasil Dibuat !"
    echo "=========================================================="
  fi
fi

echo "127.0.0.1 $domain_name" >> /etc/hosts
echo "127.0.0.1 www.$domain_name" >> /etc/hosts

systemctl restart httpd

echo "=========================================================="
echo "Berhasil Membuat Virtual Host"
echo "Domain Anda http://$domain_name"
echo "=========================================================="
echo "Vien Apps Solution https://vienapps.com/"
echo "=========================================================="
