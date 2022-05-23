#!/bin/bash

if [[ "$USER" != 'root' ]]; then
	echo "Maaf, Anda harus menjalankan ini sebagai root !!!"
	exit
fi

yum -y install yum-plugin-priorities
sed -i -e "s/\]$/\]\npriority=1/g" /etc/yum.repos.d/CentOS-Base.repo
yum -y install epel-release
sed -i -e "s/\]$/\]\npriority=5/g" /etc/yum.repos.d/epel.repo
yum -y install centos-release-scl-rh centos-release-scl
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/remi-safe.repo

wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm

wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -ivh remi-release-7.rpm

yum -y update
yum -y upgrade
yum -y install sudo
yum -y install nano
yum -y install epel-release
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
systemctl restart sshd.service
rm -f epel-release-latest-7.noarch.rpm
rm -f remi-release-7.rpm
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm
wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -ivh remi-release-7.rpm
yum clean all
yum clean dbcache
rm -rf epel-release-latest-7.noarch.rpm
rm -rf remi-release-7.rpm
rm -rf vien.sh
rm -rf /var/cache/yum
rm -rf /tmp/*
