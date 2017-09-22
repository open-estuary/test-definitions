#!/bin/sh
# Copyright (C) 2017-8-29, Linaro Limited.
#qperf is a tool for testing bandwidth and latency
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
         yum install -y qperf
         ;;
    "ubuntu")
         wget -c http://www.openfabrics.org/downloads/qperf/qperf-0.4.9.tar.gz
         tar xf qperf-0.4.9.tar.gz
         cd qperf-0.4.9
         ./configure
         make
         make install
         ;;
esac

#Test 'qperf start server'
echo "Performing qperf start server test..."
TCID="qperf-server-start"
qperf &
#perfid=`pgrep "qperf"`
#ps -A |grep "qperf" | awk '{print $1}'
count=`ps -ef | grep qperf | grep -v "grep"| wc -l`
if [ ${count} -gt 0 ]; then
    #echo "$TCID : pass"
    lava-test-case $TCID --result pass
else
    #echo "$TCID : fail"
    lava-test-case $TCID --result fail
fi

# Test 'qperf client'
echo "Performing qperf client test..."
TCID1="qperf-bw-test"
TCID2="qperf-lat-test"
qperf 127.0.0.1 tcp_bw tcp_lat 2>&1 | tee qperf-client.log
bw=`grep -Po "bw" qperf-client.log`
lat=`grep -Po "latency" qperf-client.log`
if [ "$bw" != "" ] ; then
    #echo "$TCID1 : ass"
    grep -A 1 'tcp_bw:' qperf-client.log |tail -1
    lava-test-case $TCID1 --result pass
else
    #echo "$TCID : fail"
    lava-test-case $TCID1 --result fail
fi

if [ "$lat" != "" ] ; then
    grep -A 1 'tcp_lat:' qperf-client.log |tail -1
    lava-test-case $TCID2 --result pass
else
    lava-test-case $TCID2 --result fail
fi
rm qperf-client.log
pkill qperf

