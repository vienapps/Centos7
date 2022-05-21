#!/bin/bash

if [[ "$USER" != 'root' ]]; then
	echo "Maaf, Anda harus menjalankan ini sebagai root !!!"
	exit
fi

wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm

wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -ivh remi-release-7.rpm

yum -y update
yum -y upgrade
yum install sudo -y
yum install -y epel-release
yum -y install nano
yum -y install curl
yum -y install firewalld
yum -y install openssh-server openssh-clients
yum -y install ntp
yum -y install centos-release-scl
yum -y install make gcc perl-core pcre-devel wget zlib-devel
yum makecache
yum repolist
yum --disablerepo="*" --enablerepo="epel" list available
systemctl start sshd.service
systemctl enable sshd.service
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --reload
yum clean all
yum clean dbcache
rm -rf /var/cache/yum
rm -rf /tmp/*
