#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8

clear
echo "###################################################################"
echo "                     MULAI INSTALASI !!                            "
echo "                    Script By HARVIEN !!                           "
echo "###################################################################"
sleep 3

# Make sure only root can run our script
rootness(){
    if [[ $EUID -ne 0 ]]; then
        echo "Maaf, Anda harus menjalankan ini sebagai root !!!" 1>&2
        exit 1
    fi
}

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

set_install() {
    yum -y update
    yum -y upgrade
    yum -y install sudo nano curl firewalld gcc git openssh-server openssh-clients httpd
    systemctl start firewalld
    systemctl enable firewalld
    systemctl restart firewalld
    systemctl start sshd.service
    systemctl enable sshd.service
    firewall-cmd --permanent --zone=public --add-service=ssh
    firewall-cmd --reload
    systemctl restart sshd.service
    
    wget -O /etc/environment "https://raw.githubusercontent.com/vienapp/Centos7/master/environment"
    
    echo "###################################################################"
    echo "                      Install NTP LOKAL                            "
    echo "###################################################################"
    cd
    yum -y install ntp
    wget -O /etc/ntp.conf "https://raw.githubusercontent.com/vienapp/Centos7/master/ntp.conf"
    systemctl enable ntpd && systemctl start ntpd
    ntpq -p
    timedatectl set-timezone Asia/Jakarta
    timedatectl
}

# Pre-installation settings
pre_installation_settings(){
    Set_Centos_Repo
    set_install
}

# Install Apache
install_apache(){
    echo "###################################################################"
    echo "                    Install Apache & PHP                           "
    echo "###################################################################"
    sleep 2
    
    cd
    yum -y install httpd
    systemctl start httpd.service
    systemctl enable httpd.service
    systemctl restart httpd.service
    
    echo "Pilih Versi PHP [1-4]:"
    PS3='Silahkan Pilih Nomor PHP Mana Yang Anda Install [1-4]: '
    php=("PHP_5.6" "PHP_7" "PHP_7.4" "PHP_8")
    select pilih in "${php[@]}"; do
        case $pilih in
            "PHP_5.6")
                yum -y remove php*
                yum-config-manager --disable 'remi-php*'
                yum-config-manager --enable remi-php56
                yum -y install php php-{cli,fpm,mysqlnd,zip,devel,gd,mbstring,curl,xml,pear,bcmath,json}
                systemctl restart httpd.service
                break
            ;;
            "PHP_7")
                yum -y remove php*
                yum-config-manager --disable 'remi-php*'
                yum-config-manager --enable remi-php70
                yum -y install php php-{cli,fpm,mysqlnd,zip,devel,gd,mbstring,curl,xml,pear,bcmath,json}
                systemctl restart httpd.service
                break
            ;;
            "PHP_7.4")
                yum -y remove php*
                yum-config-manager --disable 'remi-php*'
                yum-config-manager --enable remi-php74
                yum -y install php php-{cli,fpm,mysqlnd,zip,devel,gd,mbstring,curl,xml,pear,bcmath,json}
                systemctl restart httpd.service
                break
            ;;
            "PHP_8")
                yum -y remove php*
                yum-config-manager --disable 'remi-php*'
                yum-config-manager --enable remi-php80
                yum -y install php php-{cli,fpm,mysqlnd,zip,devel,gd,mbstring,curl,xml,pear,bcmath,json}
                systemctl restart httpd.service
                break
            ;;
            *) echo "Pilih Dengan Benar Antara 1 s/d 4 !!!";;
        esac
    done
    
    cp /etc/php.ini /etc/php.ini.backup
    MYPHPINI=`find /etc -name php.ini -print`
    sed -i "s/;date.timezone =/date.timezone = Asia\/Jakarta/" "$MYPHPINI"
    sed -i "s/max_execution_time\s*=.*/max_execution_time = 600/g" "$MYPHPINI"
    sed -i "s/max_input_time\s*=.*/max_input_time = 600/g" "$MYPHPINI"
    sed -i "s/; max_input_vars\s*=.*/max_input_vars = 4000/g" "$MYPHPINI"
    sed -i "s/memory_limit\s*=.*/memory_limit = -1/g" "$MYPHPINI"
    sed -i "s/post_max_size\s*=.*/post_max_size = 1536M/g" "$MYPHPINI"
    sed -i "s/upload_max_filesize\s*=.*/upload_max_filesize = 1024M/g" "$MYPHPINI"
    systemctl restart httpd.service
}

# Uninstall lamp
uninstall_lamp(){
    echo "Warning! All of your data will be deleted..."
    echo "Are you sure uninstall LAMP? (y/n)"
    read -p "(Default: n):" uninstall
    if [ -z $uninstall ]; then
        uninstall="n"
    fi
    if [[ "$uninstall" = "y" || "$uninstall" = "Y" ]]; then
        clear
        echo "==========================="
        echo "Yes, I agreed to uninstall!"
        echo "==========================="
        echo
    else
        echo
        echo "============================"
        echo "You cancelled the uninstall!"
        echo "============================"
        exit
    fi
    
    echo "Press any key to start uninstall...or Press Ctrl+c to cancel"
    char=`get_char`
    echo
    if [[ "$uninstall" = "y" || "$uninstall" = "Y" ]]; then
        cd ~
        CHECK_MARIADB=$(mysql -V | grep -i 'MariaDB')
        service httpd stop
        service mysqld stop
        yum -y remove httpd*
        if [ -z $CHECK_MARIADB ]; then
            yum -y remove mysql*
        else
            yum -y remove mariadb*
        fi
        if [ -s /usr/bin/atomic-php55-php ]; then
            yum -y remove atomic-php55-php*
            elif [ -s /usr/bin/atomic-php56-php ]; then
            yum -y remove atomic-php56-php*
            elif [ -s /usr/bin/atomic_php70 ]; then
            yum -y remove atomic-php70-php*
        else
            yum -y remove php*
        fi
        rm -rf /data/www/default/phpmyadmin
        rm -rf /etc/httpd
        rm -f /usr/bin/lamp
        rm -f /etc/my.cnf.rpmsave
        rm -f /etc/php.ini.rpmsave
        echo "Successfully uninstall LAMP!!"
    else
        echo
        echo "Uninstall cancelled, nothing to do..."
        echo
    fi
}

# Install LAMP Script
install_lamp(){
    rootness
    pre_installation_settings
    install_apache
    cd
    rm -rf /root/vien.sh
    clear
    echo
    echo 'Congratulations !!!'
    echo
}

# Initialization step
action=$1
[ -z $1 ] && action=install
case "$action" in
    install)
        install_lamp
    ;;
    uninstall)
        uninstall_lamp
    ;;
    *)
        echo "Usage: `basename $0` [install|uninstall|add|del|list]"
    ;;
esac
