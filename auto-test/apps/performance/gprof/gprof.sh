#!/bin/bash
# Copyright (C) 2017-8-29, Linaro Limited.
#qperf is a tool for testing bandwidth and latency
# Author: mahongxin <hongxin_228@163.com>

set -x

cd ../../../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -
set -x
# Test user id
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
pkgs="gcc"
#case $distro in
 #   "centos")
        install_deps "${pkgs}" 
        print_info $? install-gcc
  #      ;;
   # "ubuntu")
 #       install_deps "${pkgs}"
    #    print_info $? install-gcc
     #    ;;
#esac

gcc -g -pg gprof.c
print_info $? gcc-gprof.c

./a.out
print_info $? run-a.out

gprof a.out gmon.out > report.txt
print_info $? run-gprof


