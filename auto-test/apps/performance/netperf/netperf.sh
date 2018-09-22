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
         pkgs="wget make"
         install_deps "${pkgs}"
         wget http://htsat.vicp.cc:804/liubeijie/netperf-2.5.0.tar.gz
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
#测试能否成功启动netserver
echo "Performing netperf start server test..."
TCID="netperf-server-start"
netserver &
#计算netserver进程的行数
count=`ps -ef | grep netserver | grep -v "grep"| wc -l`
#计算结果大于0就pass
if [ ${count} -gt 0 ]; then
    print_info $? $TCID
else
    print_info $? $TCID
fi

#测试 网络带宽是否成功
#-H 主机名或IP 指定运行netserver的服务器的IP
#-l 测试时长 指定测试的时间长度，单位为秒
#-m 发送消息大小 单位为bytes
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

######################  environment  restore ##########################
rm netperf-client64.log
rm netperf-client1024.log
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

