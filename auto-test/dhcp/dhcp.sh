#!/bin/sh
#gtest is Google's Unit test tool
# Author: mahongxin <hongxin_228@163.com>
set -x
cd ../../utils
. ./sys_info.sh
cd -

#Test user id
if [ `whoami` != 'root' ]; then
    echo " You must be the superuser to run this script" >&2
    exit 1
fi
case $distro in
    "centos")
        yum install dhclient.aarch64 -y
        ;;
esac

dhclient -v -r eth0
ping 192.168.1.1

dhclient -v eth0

ping 192.168.1.1 -c 4 >> dhcp.log

str=`grep -Po "64 bytes" dhcp.log`
TCID="dhcp test"

if [ "$str" != "" ];then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi

