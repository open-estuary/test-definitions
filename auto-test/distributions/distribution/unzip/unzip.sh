#!/bin/sh
# Author: mahongxin <hongxin_228@163.com>
set -x
cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

#Test user id
if [ `whoami` != 'root' ]; then
    echo " You must be the superuser to run this script" >&2
    exit 1
fi
wget http://htsat.vicp.cc:804/netperf-2.7.0.tar.gz

tar -zxvf netperf-2.7.0.tar.gz
print_info $? tar-compressedpackage

rm -f netperf-2.7.0.tar.gz

tar -cvzf netperf-2.7.0.tar.gz netperf-2.7.0
print_info $? tar-packaging

wget http://htsat.vicp.cc:804/
setenforce 0
print_info $? open-selinux

