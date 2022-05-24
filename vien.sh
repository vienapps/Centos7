#!/bin/bash

if [[ "$USER" != 'root' ]]; then
	echo "Maaf, Anda harus menjalankan ini sebagai root !!!"
	exit
fi

cd
rm -rf /root/vien.sh
rm -rf /var/cache/yum
rm -rf /tmp/*

wget -O /etc/environment "https://raw.githubusercontent.com/vienapp/Centos7/master/environment"
sleep 2

echo "###################################################################"
echo "                		 Install NTP LOKAL                            "
echo "###################################################################"
cd
yum -y install ntp
wget -O /etc/ntp.conf "https://raw.githubusercontent.com/vienapp/Centos7/master/ntp.conf"
systemctl enable ntpd && systemctl start ntpd
ntpq -p
timedatectl set-timezone Asia/Jakarta
timedatectl
sleep 2

echo "###################################################################"
echo "                		 Install Repository                           "
echo "###################################################################"
cd
yum -y localinstall --nogpgcheck https://raw.githubusercontent.com/vienapp/Centos7/master/rpmfusion-free-release-7.noarch.rpm
yum -y localinstall --nogpgcheck https://raw.githubusercontent.com/vienapp/Centos7/master/rpmfusion-nonfree-release-7.noarch.rpm
yum -y localinstall --nogpgcheck https://raw.githubusercontent.com/vienapp/Centos7/master/epel-release-7-14.noarch.rpm
yum -y localinstall --nogpgcheck https://raw.githubusercontent.com/vienapp/Centos7/master/remi-release-7.9.rpm
rpm --import https://raw.githubusercontent.com/vienapp/Centos7/master/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://raw.githubusercontent.com/vienapp/Centos7/master/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum -y localinstall --nogpgcheck https://raw.githubusercontent.com/vienapp/Centos7/master/webtatic-release.rpm
sleep 2

yum clean all
yum update
yum -y install yum-utils
yum -y install yum-plugin-fastestmirror
yum -y install yum-plugin-priorities
yum -y install epel-release
yum -y install centos-release-scl-rh centos-release-scl
sed -i -e "s/\]$/\]\npriority=1/g" /etc/yum.repos.d/CentOS-Base.repo
sed -i -e "s/\]$/\]\npriority=5/g" /etc/yum.repos.d/epel.repo
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/remi-safe.repo

yum -y update
yum -y upgrade

echo "###################################################################"
echo "                				Install Paket                           "
echo "###################################################################"
cd
yum -y install sudo nano curl firewalld openssh-server openssh-clients
systemctl start sshd.service
systemctl enable sshd.service
firewall-cmd --permanent --zone=public --add-service=ssh
firewall-cmd --reload
systemctl restart sshd.service
systemctl start firewalld
systemctl enable firewalld
systemctl restart firewalld

yum -y update
yum -y upgrade
cd
rm -rf /root/vien.sh
rm -rf /var/cache/yum
rm -rf /tmp/*
