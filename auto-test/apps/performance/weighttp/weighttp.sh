#!/bin/sh
# Copyright (C) 2017-8-29, Linaro Limited.
#qperf is a tool for testing bandwidth and latency
# Author: mahongxin <hongxin_228@163.com>

set -x

cd ../../../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -

# Test user id
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
#distro=`cat /etc/redhat-release | cut -b 1-6`
case $distro in
    "centos")
         yum install gcc -y
         wget http://htsat.vicp.cc:804/libev-3.7.tar.gz
         print_info $? get-libev
         tar -zxvf libev-3.7.tar.gz
         print_info $? tar-libev
         cd libev-3.7
         ./configure --build=arm-linux
         make
         make install
         wget http://htsat.vicp.cc:804/weighttp-master.tar.gz
         print_info $? wget-weighttp
         tar -zxvf weighttp-master.tar.gz
         print_info $? tar-weighttp
         cd weighttp-master
         echo "/usr/local/lib" >> /etc/ld.so.conf
         /sbin/ldconfig
         ./waf configure
         ./waf build
         ./waf install
         print_info $? install-weighttp
         ;;
esac

#Test ' weighttp server'
TCID="weighttp-test"
weighttp -n 1 -k http://192.168.1.107  2>&1 | tee weighttp.log
print_info $? test-weighttp
str=`grep -Po "0 failed" weighttp.log`
if [ "$str" != "" ] ; then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID1 --result fail
fi

rm weighttp.log
pkill weighttp

