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
	packages=`apt list --installed | grep -i "mysql"|awk -F '/' '{print $1}'`
	for package in $packages
	do 
		apt remove -y $package
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
            ;;
	packages=`rpm -qa | grep -i "mariadb"`
            for package in $packages
            do
                yum remove -y $package
            done
            ;;

esac
