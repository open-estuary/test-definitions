#!/bin/bash
. ../../../utils/sh-test-lib
. ../../../utils/sys-info.sh
TCID1="ethtool inet0"
TCID2="ethtool inetx"
inet=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'`
echo $inet
ret1=`ethtool $inet|grep "Link detected: yes"|sed 's/^[ \t]*//g'`
echo $ret1
if [ "$ret1" == "Link detected: yes" ]; then
    echo pass
    lava-test-case $TCID --result pass
else
    echo fail
    lava-test-case $TCID --result fail
fi
inet1=`echo ${inet%?}`
echo $inet1
num=8
inet2=${inet1}${num}
echo $inet2
ret2=`ethtool $inet2|grep "No data available"`
echo $ret2
if [ "$ret2" == "No data available" ];then
     echo pass
     lava-test-case $TCID2 --result pass
else
     echo fial
     lava-test-case $TCID2 --result fail
fi 

