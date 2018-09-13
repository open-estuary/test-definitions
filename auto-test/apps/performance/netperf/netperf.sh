#!/bin/sh
# Copyright (C) 2017-8-30, Linaro Limited.
# Author: mahongxin <hongxin_228@163.com>
##Netperf是一种网络性能的测量工具，主要针对基于TCP或UDP的传输

set -x

#####加载外部文件################
cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib
cd -

#############################  Test user id       #########################
! check_root && error_msg "Please run this script as root."

######################## Environmental preparation   ######################
case $distro in
    "centos")
        yum install netperf -y
        print_info $? install-netperf
         ;;
    "ubuntu")
         apt-get install netperf -y
         print_info $? install-netperf
         ;;
     "fedora"|"opensuse"|"debian")
         wget -c "https://codeload.github.com/HewlettPackard/netperf/tar.gz/netperf-2.5.0" -O netperf-2.5.0.tar.gz
         tar -zxvf netperf-2.5.0.tar.gz
         cd netperf-netperf-2.5.0
         ./configure -build=alpha
         make
         make install
	 cd -
	 print_info $? install-netperf
         ;;
esac

#######################  testing the step ###########################
#Test 'netperf start server'
echo "Performing netperf start server test..."
TCID="netperf-server-start"
netserver &
count=`ps -ef | grep netserver | grep -v "grep"| wc -l`
if [ ${count} -gt 0 ]; then
    print_info $? $TCID
else
    print_info $? $TCID
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
    print_info $? $TCID1
else
   print_info $? $TCID1
fi

if [ "$throu2" != "" ] ; then
   print_info $? $TCID2
else
    print_info $? $TCID2
fi
rm netperf-client64.log
rm netperf-client1024.log

######################  environment  restore ##########################
case $distro in
    "centos")
        yum remove netperf -y
        print_info $? remove-netperf
        ;;
    "ubuntu")
        apt-get remove netperf -y
        print_info $? remove-netperf
        ;;
    "fedora"|"debian"|"opensuse")
	rm -rf netperf-netperf-2.5.0
	rm -f netperf-2.5.0.tar.gz
	print_info $? remove-netperf
	;;

esac

