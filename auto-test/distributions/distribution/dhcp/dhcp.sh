#!/bin/bash
#gtest is Google's Unit test tool
# Author: mahongxin <hongxin_228@163.com>
set -x
cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

#Test user id
if [ `whoami` != 'root' ]; then
    echo " You must be the superuser to run this script" >&2
    exit 1
fi
#distro=`cat /etc/redhat-release | cut -b 1-6`
case $distro in
    "centos")
        #yum install dhclient.aarch64 -y
        pkgs="dhclient"
        install_deps "${pkgs}"
        print_info $? install-package
        ;;
esac
ROUTE_ADDR=$(ip route list |grep default |awk '{print $3}' |head -1)
network=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'|awk '{print $1}'|head -1`
board_ip=`ip addr|grep "inet"|grep $network|cut -c 10-22|sed "s#/.*##g"`

#释放ip
dhclient $network -r -v
sleep 10
board_ip=`ip addr|grep "inet"|grep $network|cut -c 10-22|sed "s#/.*##g"`

if [ "$board_ip"x == ""x ];then
	print_info 0 delete-ip
else
	print_info 1 delete-ip
fi


#dhclient -v enahisic2i0
dhclient  $network -v
print_info $? acquiring-ip
ping -c 5 ${ROUTE_ADDR} 2>&1 |tee dhcp.log
str=`grep -Po "64 bytes" dhcp.log`
TCID="dhcp"

if [ "$str" != "" ];then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi
