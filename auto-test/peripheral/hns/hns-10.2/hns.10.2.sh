#!/bin/bash
. ../../../utils/sh-test-lib
. ../../../utils/sys_info.sh

! check_root && error_msg "This script must be run as root"

inet=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'|head -1`
echo $inet

ret1=`ifconfig $inet|grep "UP"|awk '{print $1}'|sed 's/://g'`
echo $ret1

if [ "$inet"x == "$ret1"x ];then
	print_info 0 ifconfig_inet0
	
else
	print_info 1 ifconfig_inet0 

fi


inet1=`echo ${inet%?}`
echo $inet1
num=8
inet2=${inet1}${num}
echo $inet2

#查询不存在的设备名的统计数据
ifconfig $inet2 2> 2t.txt

result=`grep 'Device not found' 2t.txt`
echo $result

if [ "$result"x != ""x ];then
	print_info 0 ifconfig_inetx 
else
	print_info 1 fconfig_inetx 

fi


#查询空设备名的统计数据
ret3=`ifconfig|grep "UP"|awk '{print $1}'|sed 's/://g'`
echo $ret3

ret4=`echo "$ret3"|grep "^e"|wc -l`
echo $ret4

if [ "$ret4" -ge 1 ];then
	print_info 0 ifconfig_none

else
	print_info 1 ifconfig_none 
fi






