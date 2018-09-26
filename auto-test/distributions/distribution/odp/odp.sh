# Copyright (C) 2017-11-08, Linaro Limited.
# Author: mahongxin <hongxin_228@163.com>
# Test user idcd -  bandwidth and latencyqperf is a tool for testing

#!/bin/bash
set -x

cd ../../../../utils

 . ./sys_info.sh
. ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
case $distro in
"centos")
     yum install wget -y
     yum install CUnit-devel.aarch64 -y
     yum install libatomic.aarch64 -y
     print_info $? install-pkgs
     wget http://192.168.50.122:8083/test_dependents/centos_odp.tar.gz
     tar xf centos_odp.tar.gz
     grep "_test" odp_centos.log > 1.log
     grep "test_in_ip" odp_centos.log >> 1.log
     awk '{print $2,$3}' 1.log > 2.log
     sed 's/\...//g' 2.log > 3.log
     ;;
 "ubuntu")
     apt-get install libcunit1-dev -y
     apt-get install wget -y
     print_info $? install-pkgs
     wget http://192.168.50.122:8083/test_dependents/debian_odp.tar.gz
     tar xf debian_odp.tar.gz
     ./debian_ubuntu/run-test.sh > odp.log
     ;;
esac

    grep "_test" odp.log > 1.log
    grep "test_in_ip" odp.log >> 1.log
    awk '{print $2,$3}' 1.log > 2.log
    sed 's/\...//g' 2.log > 3.log
while read line
do
    str1=`echo $line |awk -F ' ' '{print $1}'`
    str2=`echo $line |awk -F ' ' '{print $2}'`
    if [ "$str2" == "passed" ];then
        str2=pass
    lava-test-case $str1 --result $str2
    else
        str2=fail
   fi
#lava-test-case $str1 --result $str2
done < 3.log



