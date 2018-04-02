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
getenforce
print_info $? selinux-state

setenforce 1
print_info $? off-seliunx

setenforce 0
print_info $? open-selinux

