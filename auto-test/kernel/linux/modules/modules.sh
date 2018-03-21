#!/bin/bash

. ../../../../utils
            ./sh-test-lib
            ./sys_info.sh
OUTPUT="$(pwd)/output"
LOG="${OUTPUT}/log"
RESULT_FILE="${OUTPUT}/result"
export RESULT_FILE
! check_root && error_msg "You need to be root to run this script."
create_out_dir "${OUTPUT}"
dist_name
headers="$(uname -r)"
case "${dist}" in
    debian | ubuntu)
        apt-get install -y linux-source-estuary
        status=$?
        if [ $status -eq 0 ];then
            print_info 0 install
        else
            print_info 1 install
        fi
        apt-get install -y linux-headers-${headers}
        status=$?
        if [ $status -eq 0 ];then
            print_info 0 install
        else
            print_info 1 install
        fi
        apt-get install -y make
        print_info $? make

        apt-get install -y gcc
        print_info $? gcc
        ;;
    centos)
        yum install -y kernel-headers-${headers}
        status=$?
        if [ $status -eq 0 ];then
            print_info 0 install
        else
            print_info 1 install
        fi
        status=$?
        if [ $status -eq 0 ];then
            print_info 0 install
        else
            print_info 0 install
        fi
        #cd /root/rpmbuild/SOURCE
        #tar xvJf linux-4.12.0* -C /usr/src/kernels/
        #cd -
        yum install -y make
        yum install -y gcc
        ;;
    *)
        echo "not surpport in this distribution"
        ;;
esac
make all
status=$?
if [ $status -eq 0 ];then
    print_info 0 make_all
else
    print_info 1 make_all
fi
insmod hello.ko 
dmesg | tail -2 | tee -a "${LOG}"
cat "${LOG}" | grep Hello
status=$?
if [ $status -eq 0 ];then
    print_info 0 insmod
else
    print_info 1 insmod
fi
rmmod hello.ko
dmesg | tail -2 | tee -a "${LOG}"
cat "${LOG}" | grep Goodbye
status=$?
if [ $status -eq 0 ];then
    print_info 0 rmmod
else
    print_info 1 rmmod
fi
make clean | tee -a "${LOG}"
