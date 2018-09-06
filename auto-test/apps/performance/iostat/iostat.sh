#!/bin/bash
# Copyright (C) 2017-8-29, Estuary
# Author: wangsisi

set -x
# Test user id
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib
cd -

case $distro in
    "centos"|fedora)
        pkgs="pcp-import-iostat2pcp"
        install_deps "${pkgs}"
        print_info $? pcp-import-iostat2pcp
        ;;
    "ubuntu"|"debian")
        pkgs="sysstat"
        install_deps "${pkgs}"
        print_info $? sysstat
         ;;
esac

#显示所有设备负载情况
iostat 2>&1 
print_info $? iostat
iostat 2>&1 | tee iostat.log

#定时显示所有信息每隔2秒刷新显示，且显示3次
iostat 2 3  2>&1 
print_info $? iostat-on-time
iostat 2 3  2>&1 | tee iostat1.log

#显示指定磁盘信息
iostat -d sda1 2>&1 
print_info $? iostat-d
iostat -d sda1 2>&1 | tee iostat-d.log

#显示tty和CPu信息
iostat -t 2>&1 
print_info $? iostat-t
iostat -t 2>&1 | tee iostat-t.log

#以M为单位显示所有信息
iostat -m 2>&1 | tee iostat-m.log
print_info $? iostat-m

#查看TPS和吞吐量信息
iostat -d -k 1 1  2>&1
print_info $? iostat-d
iostat -d -k 1 1  2>&1 | tee iostat-d.log

#查看设备使用率,相应时间
iostat -d -x -k 1 1 2>&1
print_info $? iostat-x
iostat -d -x -k 1 1 2>&1 | tee iostat-x.log

#查看cpu状态
iostat -c 1 3 2>&1
print_info $? iostat-c
iostat -c 1 3 2>&1 | tee iostat-c.log

#uninstall
remove_deps "${pkgs}" 
 if test $? -eq 0;then
    print_info 0 remove
 else
    print_info 1 remove
 fi 

