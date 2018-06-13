#!/bin/bash
. ../../../../utils/sh-test-lib
. ../../../../utils/sys-info.sh
inet=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'`
echo $inet
ret1=`ethtool $inet|grep "Link detected: yes"|sed 's/^[ \t]*//g'`
echo $ret1
if [ "$ret1" == "Link detected: yes" ]; then
    print_info 0 ethtool-inet
else
    print_info 1 ethtool-inet
fi
inet1=`echo ${inet%?}`
echo $inet1
num=8
inet2=${inet1}${num}
echo $inet2
ret2=`ethtool $inet2|grep "No data available"`
echo $ret2
if [ "$ret2" == "No data available" ];then
     print_info 0 ethtool-inetx
else
     print_info 1 ethtool-inetx
fi

