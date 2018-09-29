#!/bin/bash
systemctl stop mysql
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

