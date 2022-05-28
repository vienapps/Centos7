#!/bin/bash
clear
echo "###################################################################"
echo "                     MULAI INSTALASI !!                            "
echo "                    Script By HARVIEN !!                           "
echo "###################################################################"
sleep 10

Centos6Check=$(cat /etc/redhat-release | grep ' 6.' | grep -iE 'centos|Red Hat')
if [ "${Centos6Check}" ]; then
    echo "Sorry, Centos 6 Tidak Support Dengan Script Ini !!!"
    exit 1
fi

Centos8Check=$(cat /etc/redhat-release | grep ' 8.' | grep -iE 'centos|Red Hat')
if [ "${Centos6Check}" ]; then
    echo "Sorry, Centos 8 Tidak Support Dengan Script Ini !!!"
    exit 1
fi

UbuntuCheck=$(cat /etc/issue | grep Ubuntu | awk '{print $2}' | cut -f 1 -d '.')
if [ "${UbuntuCheck}" -lt "16" ]; then
    echo "Sorry, OS Tidak Support Dengan Script Ini !!!"
    exit 1
fi

if [[ "$USER" != 'root' ]]; then
    echo "Maaf, Anda harus menjalankan ini sebagai root !!!"
    exit
fi

cd
rm -rf /root/vien.sh
rm -rf /var/cache/yum
rm -rf /tmp/*
yum clean all

wget -O /etc/environment "https://raw.githubusercontent.com/vienapp/Centos7/master/environment"
sleep 3

echo "###################################################################"
echo "                      Install NTP LOKAL                            "
echo "###################################################################"
sleep 3
cd
yum -y install ntp
wget -O /etc/ntp.conf "https://raw.githubusercontent.com/vienapp/Centos7/master/ntp.conf"
systemctl enable ntpd && systemctl start ntpd
ntpq -p
timedatectl set-timezone Asia/Jakarta
timedatectl

echo "###################################################################"
echo "                      Install Repository                           "
echo "###################################################################"
sleep 3

cd
Set_Centos_Repo() {
    HUAWEI_CHECK=$(cat /etc/motd | grep "Huawei Cloud")
    if [ "${HUAWEI_CHECK}" ] && [ "${is64bit}" == "64" ]; then
        \cp -rpa /etc/yum.repos.d/ /etc/yumBak
        sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*.repo
        sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.epel.cloud|g' /etc/yum.repos.d/CentOS-*.repo
        rm -f /etc/yum.repos.d/epel.repo
        rm -f /etc/yum.repos.d/epel-*
    fi
    ALIYUN_CHECK=$(cat /etc/motd | grep "Alibaba Cloud ")
    if [ "${ALIYUN_CHECK}" ] && [ "${is64bit}" == "64" ] && [ ! -f "/etc/yum.repos.d/Centos-vault-8.5.2111.repo" ]; then
        rename '.repo' '.repo.bak' /etc/yum.repos.d/*.repo
        wget https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo -O /etc/yum.repos.d/Centos-vault-8.5.2111.repo
        wget https://mirrors.aliyun.com/repo/epel-archive-8.repo -O /etc/yum.repos.d/epel-archive-8.repo
        sed -i 's/mirrors.cloud.aliyuncs.com/url_tmp/g' /etc/yum.repos.d/Centos-vault-8.5.2111.repo && sed -i 's/mirrors.aliyun.com/mirrors.cloud.aliyuncs.com/g' /etc/yum.repos.d/Centos-vault-8.5.2111.repo && sed -i 's/url_tmp/mirrors.aliyun.com/g' /etc/yum.repos.d/Centos-vault-8.5.2111.repo
        sed -i 's/mirrors.aliyun.com/mirrors.cloud.aliyuncs.com/g' /etc/yum.repos.d/epel-archive-8.repo
    fi
    MIRROR_CHECK=$(cat /etc/yum.repos.d/CentOS-Linux-AppStream.repo | grep "[^#]mirror.centos.org")
    if [ "${MIRROR_CHECK}" ] && [ "${is64bit}" == "64" ]; then
        \cp -rpa /etc/yum.repos.d/ /etc/yumBak
        sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*.repo
        sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.epel.cloud|g' /etc/yum.repos.d/CentOS-*.repo
    fi
}
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

echo "###################################################################"
echo "                        Update Paket                               "
echo "###################################################################"
sleep 3
yum -y update && yum -y upgrade

echo "###################################################################"
echo "                           Install Paket                           "
echo "###################################################################"
sleep 3
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

echo "###################################################################"
echo "                           Pembersihan                             "
echo "###################################################################"
sleep 7
cd
rm -rf /root/vien.sh
rm -rf /var/cache/yum
rm -rf /tmp/*
clear
echo "###################################################################"
echo "                    INSTALASI SELESAI !!                           "
echo "                    Script By HARVIEN !!                           "
echo "###################################################################"
