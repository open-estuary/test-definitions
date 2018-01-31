# Copyright (C) 2017-11-08, Linaro Limited.
# Author: mahongxin <hongxin_228@163.com>
# Test user idcd -  bandwidth and latencyqperf is a tool for testing

#!/bin/sh
set -x

cd ../../../../utils

 . ./sys_info.sh

cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
#distro=`cat /etc/redhat-release | cut -b 1-6`
case $distro in
"centos")
     yum install make -y
     wget ftp://ftp.hpl.hp.com/pub/httperf/httperf-0.9.0.tar.gz
     tar -zxvf httperf-0.9.0.tar.gz
     cd httperf-0.9.0
     ./configure --build=arm-linux
     make
     make install
     print_info $? install-package
     ;;
 "ubuntu")
     apt-get install httperf -y
     print_info $? install-package
     ;;
esac
#Test ' httperf server'

httperf --server sina.com.cn --num-conn 300 --rate 30 2>&1 | tee httperf.log
print_info $? httper-test
$TCID="httperf-test"

str=`grep -Po "total 0" httperf.log`

if [ "$str" != "" ] ; then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result faile
fi

pkill httperf

rm httperf.log
case $distro in
    "centos")
        yum remove make -y
        rm -f httperf-0.9.0.tar.gz
        rm -rf httperf-0.9.0
        print_info $? remove-httperf
        ;;
    "ubuntu")
        apt-get remove httperf -y
        print_info $? remove-httperf
        ;;
esac


