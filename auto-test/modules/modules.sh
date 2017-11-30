#!/bin/bash

. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
LOG="${OUTPUT}/log"
RESULT="${OUTPUT}/result"
export RESULT_FILE
! check_root && error_msg "You need to be root to run this script."
create_out_dir "${OUTPUT}"
dist_name
headers="$(uname -r)"
case "${dist}" in
    debian | ubuntu)
        apt-get install linux-headers-${headers}
        ;;
    centos)
        yum install kernel-headers-${headers}
        ;;
    *)
        echo "not surpport in this distribution"
        ;;
esac
make all
status=$?
if [ $status -eq 0 ];then
    echo "make hello.c PASS" | tee -a "${RESULT_FILE}"
else
    echo "make hello.c FAILED" | tee -a "${RESULT_FILE}"
fi
insmod hello.ko | tee -a "${LOG}" 
rmmod hello.ko | tee -a "${LOG}"
make clean | tee -a "${LOG}"
dmesg | tail -2 | tee -a text.log
cat text.log | grep Hello
status=$?
if [ $status -eq 0 ];then
    echo "insmod PASS" | tee -a "${RESULT_FILE}"
else
    echo "insmod FAILED" | tee -a "${RESULT_FILE}"
fi
cat text.log | grep Goodbye
status=$?
if [ $status -eq 0 ];then
    echo "rmmod PASS" | tee -a "${RESULT_FILE}"
else
    echo "rmmod FAILED" | tee -a "${RESULT_FILE}"
fi
