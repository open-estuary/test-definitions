#!/bin/sh
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
    "ubuntu")
        #apt-get install dhclient -y
        pkgs="dhclient"
        install_deps "${pkgs}"
        print_info $? install-package
        ;;

esac
ROUTE_ADDR=$(ip route list |grep default |awk '{print $3}' |head -1)
dhclient -v -r eth0
ping -c 5 ${ROUTE_ADDR}
print_info $? delete-ip

dhclient -v eth0
print_info $? acquiring-ip
ping -c 5 ${ROUTE_ADDR} 2>&1 |tee dhcp.log

str=`grep -Po "64 bytes" dhcp.log`
TCID="dhcp"

if [ "$str" != "" ];then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi
