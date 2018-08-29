#!bin/bash
. ../../../utils/sh-test-lib
. ../../../utils/sys_info.sh

#GE网口详细统计数据获取容错测试
inet=`ip link|egrep "enahisic2i3|eth3"|awk '{print $2}'|sed 's/://g'`
echo $inet
res1=`ethtool -S $inet|grep "NIC statistics:"`
if [ "$res1"x == "NIC statistics:"x ];then
	print_info 0 ethtool_eth3
else
	print_info 1 ethtool_eth3
fi

#查询不存在设备名的统计数据
inet1=`echo ${inet%?}`
num=8
inet2=${inet1}${num}
ethtool -S $inet2 2> 6t1.txt
result=`grep "No such device" 6t1.txt`
if [ "$result"x != ""x ];then
	print_info 0 ethtool_eth8
else 
	print_info 1 ethtool_eth8
fi

#查询空设备名的统计数据
ethtool -S 2> 6t2.txt
result1=`grep "bad command line" 6t2.txt`
if [ "result1"x != ""x ];then
	print_info 0 ethtool_none
else
	print_info 1 ethtool_none
fi










