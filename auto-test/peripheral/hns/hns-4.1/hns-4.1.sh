#!/bin/bash
. ../../../utils/sh-test-lib
. ../../../utils/sys_info.sh
inet=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'`
TCID1="off-autoneg"
TCID2="10-half"
TCID3="10-full"
TCID4="100-half"
TCID5="100-full"
TCID6="1000-full"
TCID7="1000-half"
echo $inet
#关闭自协商
#ethtool -A $inet autoneg off
#ret=`ethtool -a $inet |grep "Autonegotiate"|awk '{print $2}'`
#echo $ret
#if [ "$ret" == "off" ];then
 #   echo pass
  #  lava-test-case $TCID1 --result pass
#else
 #   echo fail
  #  lava-test-case $TCID1 --result fail
#fi
#echo 22222
#设置网口为10M 半双工
num="10 100"
for i in $num;
do
  echo $i
  echo $inet
  ethtool -s $inet speed $i duplex half
  sleep 5
  #ret4=`ethtool enahisic2i0 |grep "Speed"|sed 's/^[ \t]*//g'`
  ret2=`ethtool $inet |grep "Speed"|sed 's/^[ \t]*//g'`
  ret3=`ethtool $inet |grep "Duplex"|sed 's/^[ \t]*//g'`
  str="Speed: "${i}"Mb/s"
  echo $ret2
  echo $ret3
  echo $str
  if [ "$ret2" == "$str" -a "$ret3" == "Duplex: Half" ];then
       echo pass
       lava-test-case ${i}half --result pass
  else
       echo fail
       lava-test-case ${i}half --result fail
  fi
done
#设置网口为10M,100M,1000M 全双工
number="10 100 1000"
for i in $number
 do
   ethtool -s $inet speed $i duplex full
   sleep 5
   ret2=`ethtool $inet |grep "Speed" |sed 's/^[ \t]*//g'`
   ret3=`ethtool $inet |grep "Duplex"|sed 's/^[ \t]*//g'`
   str="Speed: "${i}"Mb/s"
   if [ "$ret2" == "$str" -a "$ret3" == "Duplex: Full" ];then
        echo pass
        lava-test-case ${i}full --result pass
   else
        echo fail
        lava-test-case ${i}full --result fail
   fi
done
#设置为1000Mb/s 不支持此模式
ret2=`ethtool -s $inet speed 1000 duplex half`
sleep 5
if [ "$ret2" == "" ];then
    echo pass
    lava-test-case $TCID4 --result pass
else
    echo fail
    lava-test-case $TCID4 --result fail
fi



