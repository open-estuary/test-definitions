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
case $distro in
    "centos")
        yum install snappy.aarch64 -y
        yum install gcc-c++ -y
        yum install libtool -y
         ;;
esac
cat <<EOF >>./a.cpp
#include "snappy.h"
#include <string>
#include <iostream>
int main(){
        std::string s = "ddslkfslkdf;lfksjdlf;sdlkfjlsd;sdflkjl";
        std::string d;
        snappy::Compress(s.data(),s.size(),&d);
        std::cout<<d<<std::endl;
        std::cout<<s.size()<<""<<d.size()<<std::endl;
        return 0;
}
EOF
libtool --mode=compile g++ -c a.cpp
libtool --mode=link g++ -o test a.lo /usr/lib64/libsnappy.so.1
./test >> snappy.log
TCID="snappy-test"
str=`grep -Po "error" snappy.log`
if [ "$str" != "" ] ; then
    lava-test-case $TCID --result fail
else
    lava-test-case $TCID --result pass
fi
rm snappy.log
pkill snappy

