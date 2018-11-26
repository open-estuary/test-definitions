#!/bin/bash

set -x
cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib

cd -

! check_root && error_msg "This script must be run as root"

pkgs="wget curl ufw"
install_deps "${pkgs}"

# download and install grafana
case "${distro}" in
    centos)
	wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-5.2.4-1.aarch64.rpm
	yum localinstall grafana-5.2.4-1.aarch64.rpm -y
	print_info $? install_grafana
	;;
    debian)
	apt-get install libfontconfig1 -y
	wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_5.3.2_arm64.deb
	dpkg -i grafana_5.3.2_arm64.deb
	print_info $? install_grafana
	;;
esac

# cfgfile check
find /etc/grafana/grafana.ini 
if test $? -eq 0;then
    print_info 0 cfgfile_check
else
    print_info 1 cfgfile_check
fi

#启动grafana服务
systemctl daemon-reload
systemctl start grafana-server
systemctl status grafana-server|grep "running"
print_info $? start_grafana
 

#grafana默认使用3000端口,需打开端口
case "${distro}" in
   centos)
	systemctl start firewalld
	firewall-cmd --zone=public --add-port=3000/tcp --permanent
	firewall-cmd --reload
	;;
   debian)
	apt install -y ufw
	ufw disable
	;;
esac

IFCONFIG=`ip link|grep "state UP"|awk '{print $2}'|sed "s/://g"|head -1`
IP=`ip a|grep ${IFCONFIG}|grep "inet "|awk '{print $2}'|cut -d '/' -f 1`

#查看是否能使用浏览器访问grafana
curl -o "output" "http://${IP}:3000/login/"
grep 'Grafana' ./output
#print_info $? grafana_web


#remove grafana
case "${distro}" in
    centos)
	systemctl stop grafana-server
	package=`rpm -qa|grep "grafana"`
	yum remove $package -y
	print_info $? remove_grafana
	rm -rf grafana-5.2.4-1.aarch64.rpm
	;;
    debian)
	systemctl stop grafana-server
	package=`apt list --installed|grep -i "grafana"|awk -F '/' '{print $1}'`
	apt remove $package -y
	print_info $? remove_grafana
	rm -rf grafana_5.3.2_arm64.deb
	;;
esac






 











