#!/bin/sh
# Copyright (C) 2017-12-28.
#search engine
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
        yum install jmeter.noarch -y
        print_info $? install-jmeter
         ;;
esac
TCID="jmeter-test"

./jmeter -n -t my_test.jmx -l test.jtl 2>&1 | tee jmeter.log
print_info $? run-jmeter

str=`grep -Po "successfully " jmeter.log`
if [ "$str" != "" ] ; then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi

pkill jmeter
print_info $? kill-jmeter
case $distro in
    "centos")
        yum remove jmeter -y
        print_info $? remove-jmeter
        ;;
esac
