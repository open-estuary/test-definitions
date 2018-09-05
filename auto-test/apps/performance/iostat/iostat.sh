#!/bin/sh
# Copyright (C) 2017-8-29, Linaro Limited.
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
case $distro in
    "centos"|fedora)
        yum install pcp-import-iostat2pcp -y
        print_info $? pcp-import-iostat2pcp
        ;;
    "ubuntu")
        apt-get install sysstat -y
        print_info $? sysstat
         ;;
esac

#显示所有设备负载情况
iostat 2>&1 | tee iostat.log
print_info $? iostat

#定时显示所有信息每隔2秒刷新显示，且显示3次
iostat 2 3  2>&1 | tee iostat1.log
print_info $? iostat-on-time

#显示指定磁盘信息
iostat -d sda1 2>&1 | tee iostat-d.log
print_info $? iostat-d

#显示tty和CPu信息
iostat -t 2>&1 | tee iostat-t.log
print_info $? iostat-t

#以M为单位显示所有信息
iostat -m 2>&1 | tee iostat-m.log
print_info $? iostat-m

#查看TPS和吞吐量信息
iostat -d -k 1 1  2>&1 | tee iostat-d.log
print_info $? iostat-d

#查看设备使用率,相应时间
iostat -d -x -k 1 1 2>&1 | tee iostat-x.log
print_info $? iostat-x

#查看cpu状态
iostat -c 1 3 2>&1 | tee iostat-c.log
print_info $? iostat-c

case $distro in
    "ubuntu|debian")
     apt-get remove systat -y
     print_info $? remove-systat
     ;;
 "centos"|"fedora")
    yum remove pcp-import-iostat2pcp -y
    print_info $? remove-pcp-import-iostat2pcp
    ;;
esac


