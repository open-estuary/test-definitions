#!/bin/bash
systemctl stop mysql
packages=`apt list --installed | grep -i "mysql"|awk -F '/' '{print $1}'`
for package in $packages
do 
	apt remove -y $package
done

