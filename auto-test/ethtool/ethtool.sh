#!/bin/sh
# Copyright (C) 2017-8-29, Linaro Limited.
# Author: mahongxin <hongxin_228@163.com>

set -x

cd ../../utils
    . ./sys_info.sh
cd -

# Test user id
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
case $distro in
    "ubuntu")
        apt-get install ethtool -y
        print_info $? install-ethtool
         ;;
esac
str1="enahisic2i0"
#1.查看网卡的速度
ethtool "${str1}"
print_info $? ethtool-enahisic2i0

#2.获取网卡的帮助信息
ethtool -h
print_info $? ethtool-h

#3.查看网卡enahisic2i0采用了那种驱动
ethtool -i "${str1}"
print_info $? ehtool-i-enahisic2i0

#4.查看网卡在接受/发送数据时，有没有出错
ethtool -S "${str1}"
print_info $? ethtool-S-enahisic2i0

#5.将千兆网卡速度降为百兆
ethtool -s "${str1}" speed 100 duplex full 2>&1 | tee speed.log
speed=`grep -Po "100" speed.log`
if [ "$speed" != ""] ; then
   lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi

#6.查询网口的注册性信息
ethtool -d "${str1}"
print_info $? ethtool-d-enahisic2i0

#7.重置网口到自适应模式
ethtool -r "${str1}"
print_info $? ethtool-r-enahisic2i0

rm speed.log
pkill ethtool

