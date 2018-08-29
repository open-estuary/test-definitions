#!/bin/bash
. ../../../utils/sh-test-lib
. ../../../utils/sys_info.sh

! check_root && error_msg "This script must run as root"
ret=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'`
echo $ret > 3t.txt

#遍历设备上的所有XGE口，获取网口统计数据
for i in `cut -d '' -f 1 3t.txt`;do
	echo $i
	res=`ethtool $i|grep "Speed"`
	echo $res
	if [[ $res == *"Speed: 10000Mb/s"* ]];then
		XGE_INFO=`ifconfig $i|grep "UP"|awk '{print $1}'|sed 's/://g'`
		echo $XGE_INFO
		if [ $XGE_INFO == $i ];then
			print_info 0 XGE_ifconfig
		else 
			print_info 1 XGE_ifconfig
		fi
	else
		echo "This is not a XEG --pass"
		print_info 0 XGE_ifconfig
	fi
done


		

