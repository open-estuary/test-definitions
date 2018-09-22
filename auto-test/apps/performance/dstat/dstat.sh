#!/bin/sh
# Copyright (C) 2017-8-29, Linaro Limited.
# Author: mahongxin <hongxin_228@163.com>
##dstat是一个监控工具，用于收集监控cpu、内存、设备IO等系统资源的占用情况

set -x
#####加载外部文件################
cd ../../../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -

#############################  Test user id       #########################
! check_root && error_msg "Please run this script as root."

######################## Environmental preparation   ######################
case $distro in
    "debian"|"ubuntu"|"fedora"|"centos"|"opensuse")
        package="dstat"
        install_deps "${package}"
        print_info $? install-dstat
         ;;
esac
#######################  testing the step ###########################
#输出默认监控，报表 输出时间间隔为3s,输出10个结果
dstat 3 10  2>&1 | tee dstat.log
print_info $? dstat

#查看内存占用情况
dstat -g -l -m -s --top-mem 3 10 2>&1 | tee -a dstat.log
print_info $? dstat-g

#显示一些关于cpu资源损耗的数据
dstat -c -y -l --proc-count --top-cpu 3 10 2>&1 | tee -a dstat.log
print_info $? dstat-c

#查看当前占用I/O,cpu,内存等最高的进程信息
dstat --top-mem --top-io --top-cpu 3 10 2>&1 | tee -a dstat.log
print_info $? dstat-top

#查看某个cpu状态信息
dstat -c 0,1 3 10 2>&1 | tee -a dstat.log
print_info $? dstat-c-01

#查看系统的磁盘的读写数据大小
dstat -d 3 10 2>&1 | tee -a dstat.log

print_info $? dstat-d
#查看系统网络状态
dstat -n 3 10 2>&1 | tee -a dstat.log
print_info $? dstat-n

#查看系统负载情况
dstat -l 3 10 2>&1 | tee -a dstat.log
print_info $? dstat-l

#查看系统进程信息
dstat -p 3 10 2>&1 | tee -a dstat.log
print_info $? dstat-p

#查看系统tcp,udp端口情况
dstat --socket 3 10 2>&1 | tee -a dstat.log
print_info $? dstat-socket

#查看I/o请求情况
dstat -r 3 10 2>&1 | tee -a dstat.log
print_info $? dstat-r

######################  environment  restore ##########################
case $distro in
    "ubuntu"|"debian"|"centos"|"fedora"|"opensuse")
     remove_deps "${package}"
     print_info $? remove-dstat
    ;;
esac


