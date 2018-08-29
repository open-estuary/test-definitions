#!/bin/bash
. ../../../utils/sh-test-lib
. ../../../utils/sys_info.sh

! check_root && error_msg "This script must run as root"

inet=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'|head -1`
echo $inet

for i in $(seq 10);do
	echo $i
	INFO=`ethtool -l $inet|grep "Pre-set"|awk '{print $1}'`
	if [ $INFO == "Pre-set" ];then
		print_info 0 ethtool
	else
		print_info 1 ethtool
	fi
done




