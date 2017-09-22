#!/bin/sh
# Copyright (C) 2017-8-30, Linaro Limited.
#netperf is a network performance measurement tool,mainly for TCP or UDP transmission
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
#name=`uname -a | awk '{print $2}'`
case $distro in
    "centos")
         wget http://htsat.vicp.cc:804/netperf-2.7.0.tar.gz
         tar xf netperf-2.7.0.tar.gz
         cd netperf-2.7.0
         ./configure --build=aarch64-unknown-linux-gnu
         make
         make install
         ;;
    "ubuntu")
         apt-get install netperf -y
         ;;
esac

#Test 'netperf start server'
echo "Performing netperf start server test..."
TCID="netperf-server-start"
netserver &
count=`ps -ef | grep netserver | grep -v "grep"| wc -l`
if [ ${count} -gt 0 ]; then
    #echo "$TCID : pass"
    lava-test-case $TCID --result pass
else
    #echo "$TCID : fail"
    lava-test-case $TCID --result fail
fi

# Test 'netperf client'
echo "Performing netperf client test..."
TCID1="netperf-64-test"
TCID2="netperf-1024-test"
netperf -H 127.0.0.1 -l 60 -- -m 64 2>&1 | tee netperf-client64.log
netperf -H 127.0.0.1 -l 60 -- -m 1024 2>&1 |tee netperf-client1024.log
throu1=`grep -Po "Throughput" netperf-client64.log`
throu2=`grep -Po "Throughput" netperf-client1024.log`
if [ "$throu1" != "" ] ; then
    #echo "$TCID1 : ass"
   # grep -A 1 'tcp_bw:' qperf-client.log |tail -1
    lava-test-case $TCID1 --result pass
else
    #echo "$TCID : fail"
    lava-test-case $TCID1 --result fail
fi

if [ "$throu2" != "" ] ; then
   # grep -A 1 'tcp_lat:' qperf-client.log |tail -1
    lava-test-case $TCID2 --result pass
else
    lava-test-case $TCID2 --result fail
fi
rm netperf-client64.log
rm netperf-client1024.log
pkill netserver

