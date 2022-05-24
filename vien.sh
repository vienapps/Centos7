#!/bin/bash

if [[ "$USER" != 'root' ]]; then
	echo "Maaf, Anda harus menjalankan ini sebagai root !!!"
	exit
fi

wget -O /etc/environment "https://raw.githubusercontent.com/vienapp/Centos7/master/environment"

yum -y install ntp
wget -O /etc/ntp.conf "https://raw.githubusercontent.com/vienapp/Centos7/master/ntp.conf"
systemctl enable ntpd && systemctl start ntpd
ntpq -p
timedatectl set-timezone Asia/Jakarta
timedatectl

export LANG=en_US.UTF-8 && export LANGUAGE=en_US.UTF-8 && export LC_COLLATE=C && export LC_CTYPE=en_US.UTF-8 && yum check

yum -y install yum-plugin-fastestmirror
yum -y install yum-plugin-priorities
sed -i -e "s/\]$/\]\npriority=1/g" /etc/yum.repos.d/CentOS-Base.repo
yum -y install epel-release
sed -i -e "s/\]$/\]\npriority=5/g" /etc/yum.repos.d/epel.repo
yum -y install centos-release-scl-rh centos-release-scl
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/remi-safe.repo
yum -y install centos-release-scl
yum -y install make gcc perl-core pcre-devel wget zlib-devel
yum --disablerepo="*" --enablerepo="epel" list available

yum -y update
yum -y upgrade
yum -y install sudo nano curl firewalld openssh-server openssh-clients
systemctl start sshd.service
systemctl enable sshd.service
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --reload
systemctl restart sshd.service
yum makecache
yum clean all
yum clean dbcache
yum -y update
yum -y upgrade
rm -rf vien.sh
rm -rf /var/cache/yum
rm -rf /tmp/*
