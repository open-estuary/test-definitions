#!/bin/sh
# Copyright (C) 2017-8-29, Linaro Limited.
#qperf is a tool for testing bandwidth and latency
# Author: mahongxin <hongxin_228@163.com>

set -x

# Test user id
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

cd ../../../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -

#name=`uname -a | awk '{print $2}'`
#distro=`cat /etc/redhat-release | cut -b 1-6`
case $distro in
    "centos")
         yum install -y qperf
         print_info $? install-qperf
         ;;
    "ubuntu")
         apt-get install gcc -y
         apt-get install make -y
         apt-get install qperf -y
         #wget -c http://www.openfabrics.org/downloads/qperf/qperf-0.4.9.tar.gz
         #tar xf qperf-0.4.9.tar.gz
         #cd qperf-0.4.9
         #./configure
         #make
         #make install
         print_info $? install-qperf
         ;;
    "fedora")
	    pkgs="qperf.aarch64"
	    install_deps "${pkgs}"
	    print_info $? install-qperf
	    ;;
    "opensuse")
	    pkgs="qperf"
	   install_deps "${pkgs}"
	   print_info $? install-qperf
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
print_info $? qperf-client-start
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

kill -9 $(pidof qperf)
print_info $? stop-qperf

rm qperf-client.log
print_info $? rm-log
case $distro in
    "ubuntu")
        apt-get remove gcc make -y
        print_info $? remove-package
        ;;
    "centos")
       yum remove qperf -y
       print_info $? remove-package
       ;;
    "fedora"|"opensuse")
	    remove_deps "${pkgs}"
	    print_info $? remove-pkgs
	    ;;

esac
