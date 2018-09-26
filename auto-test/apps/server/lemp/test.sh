#!/bin/bash
set -x

cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib
cd -

case "$distro" in 
    ubuntu|debian)

	systemctl stop apache2 > /dev/null 2>&1 || true
	systemctl stop mysql
	packages1=`apt list --installed | grep -i "mysql"|awk -F '/' '{print $1}'`
	for package_a in $packages1
	do 
		apt remove -y $package_a
	done

	packages2=`apt list --installed | grep -i "mysql"|awk -F '/' '{print $1}'`
        for package_b in $packages2
        do
                apt remove -y $package_b
        done

	;;
    centos|fedora)
	systemctl stop httpd.service > /dev/null 2>&1 || true
	systemctl stop mysql
	packages=`rpm -qa | grep -i "mysql"`
            for package in $packages
            do
                yum remove -y $package
            done
            
	packages=`rpm -qa | grep -i "mariadb"`
            for package in $packages
            do
                yum remove -y $package
            done
	rm -rf /var/lib/mysql /var/log/mysqld.log /var/log/mysql   /var/run/mysqld /mysql /percona
	userdel -r mysql

            ;;

esac
