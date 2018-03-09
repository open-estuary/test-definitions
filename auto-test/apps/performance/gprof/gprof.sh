#!/bin/sh
# Copyright (C) 2017-8-29, Linaro Limited.
#qperf is a tool for testing bandwidth and latency
# Author: mahongxin <hongxin_228@163.com>

set -x

cd ../../../../utils
    . ./sys_info.sh
cd -

# Test user id
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
case $distro in
    "centos")
        yum install gcc -y
        print_info $? install-gcc
        ;;
    "ubuntu")
        apt-get install gcc -y
        print_info $? install-gcc
         ;;
esac

gcc -g -pg gprof.c
print_info $? gcc-gprof.c

./a.out
print_info $? run-a.out

gprof a.out gmon.out > report.txt
print_info $? run-gprof

case $distro in
    "ubuntu")
        apt-get remove gcc -y
        print_info $? remove-gcc
        ;;
    "centos")
        yum remove gcc -y
        print_info $? remove-gcc
        ;;
esac

