#!/bin/bash
#gtest is Google's Unit test tool
# Author: mahongxin <hongxin_228@163.com>
#-x 会显示命令执行的语句和参数
set -x
#进入到相对路径执行命令，并通过 cd - 返回
cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -
#检查是否是root用户
#Test user id
if [ `whoami` != 'root' ]; then
    echo " You must be the superuser to run this script" >&2
    exit 1
fi
#检查是否可以安装dhcp包
#distro=`cat /etc/redhat-release | cut -b 1-6`
case $distro in
    "centos")
        #yum install dhclient.aarch64 -y
        pkgs="dhclient"
        install_deps "${pkgs}"
        print_info $? install-package
        ;;
     "ubuntu")
	pkgs="isc-dhcp-server"
	install_deps "${pkgs}"
	print_info $? install-package
	;;
     "fedora")
	pkgs="dhcp-client.aarch64"
        install_deps "${pkgs}"
        print_info $? install-package
        ;;
     "opensuse")
	pkgs="dhcp-client"
	install_deps "${pkgs}"
	print_info $? install-package
	;;
     "debian")
	pkgs="isc-dhcp-client"
	install_deps "${pkgs}"
	print_info $? install-package
	;;

esac
#获取IP地址
ROUTE_ADDR=$(ip route list |grep default |awk '{print $3}' |head -1)
#获取到激活的网卡名称
inet=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'|awk '{print $1}'| head -1`
echo $inet
#执行dhclient命令，并ping前面获取到的ip地址，看是否可以ping的通

#dhclient -v -r enahisic2i0
dhclient -v -r $inet
ping -c 5 ${ROUTE_ADDR} >1.txt 2>&1
cat 1.txt|grep -i "unreachable"
print_info $? delete-ip

#dhclient -v enahisic2i0
dhclient -v $inet
print_info $? acquiring-ip
ping -c 5 ${ROUTE_ADDR} 2>&1 |tee dhcp.log
#检查ping的log中是否包含 64 bytes 这个字符串
str=`grep -Po "64 bytes" dhcp.log`
TCID="dhcp"
#检测到特定字符串的话，说明dhclient命令执行成功
if [ "$str" != "" ];then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi
