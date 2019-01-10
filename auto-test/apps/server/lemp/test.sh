#!/bin/bash
set -x

cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib
cd -

case "$distro" in 
    ubuntu|debian)
	systemctl stop mysql
        systemctl stop php7.0-fpm
        systemctl stop nginx
        systemctl stop apache2

	packages1=`apt list --installed | grep -i "mysql"|awk -F '/' '{print $1}'`
	for package_a in $packages1
	do 
		apt remove -y $package_a
	done

	packages2=`apt list --installed | grep -i "mariadb"|awk -F '/' '{print $1}'`
        for package_b in $packages2
        do
                apt remove -y $package_b
        done

	packages3=`apt list --installed | grep -i "php"|awk -F '/' '{print $1}'`
        for package_c in $packages3
        do
                apt remove -y $package_c
        done

	packages4=`apt list --installed | grep -i "nginx"|awk -F '/' '{print $1}'`
        for package_d in $packages4
        do
                apt remove -y $package_d
        done

	packages5=`apt list --installed | grep -i "apache2"|awk -F '/' '{print $1}'`
        for package_e in $packages5
        do
                apt remove -y $package_e
        done

	;;
    centos|fedora)
	systemctl stop nginx
        systemctl stop httpd
        systemctl stop php-fpm
	systemctl stop mysql

	packages1=`rpm -qa | grep -i "mysql"`
            for package_a in $packages1
            do
                yum remove -y $package_a
            done
            
	packages2=`rpm -qa | grep -i "mariadb"`
            for package_b in $packages2
            do
                yum remove -y $package_b
            done
	rm -rf /var/lib/mysql /var/log/mysqld.log /var/log/mysql   /var/run/mysqld /mysql /percona
	userdel -r mysql


            ;;

esac
