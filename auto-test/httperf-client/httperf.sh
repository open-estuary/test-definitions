# Copyright (C) 2017-11-08, Linaro Limited.
# Author: mahongxin <hongxin_228@163.com>
# Test user idcd -  bandwidth and latencyqperf is a tool for testing

#!/bin/sh
set -x

cd ../../utils

 . ./sys_info.sh

cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
#distro=`cat /etc/redhat-release | cut -b 1-6`
case $distro in
"centos")
     wget ftp://ftp.hpl.hp.com/pub/httperf/httperf-0.9.0.tar.gz
     tar -zxvf httperf-0.9.0.tar.gz
     cd httperf-0.9.0
     ./configure --build=arm-linux
     make
     make install
     ;;
esac
#Test ' httperf server'

httperf --server sina.com.cn --num-conn 300 --rate 30 2>&1 | tee httperf.log

$TCID="httperf-test"

str=`grep -Po "total 0" httperf.log`

if [ "$str" != "" ] ; then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result faile
fi

pkill httperf

rm httperf.log
