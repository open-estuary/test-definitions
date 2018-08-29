#!/bin/bash
. ../../../utils/sh-test-lib
. ../../../utils/sys_info.sh


! check_root && error_msg "This script must be run as root"

inet=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'|head -1`
echo $inet

#查询网卡信息
ret=`ifconfig $inet|grep "UP"|awk '{print $1}'|sed 's/://g'`

if [ "$inet"x == "$ret"x ];then
	
	print_info 0 inet_info
else
	
	print_info 1 inet_info

fi










