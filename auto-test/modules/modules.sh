#!/bin/bash

. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
! check_root && error_msg "You need to be root to run this script."
make
export RESULT_FILE
! check_root && error_msg "You need to be root to run this script."
create_out_dir "${OUTPUT}"

make all
status=$?
if [ $status -eq 0 ];then
    echo "make hello.c PASS" | tee -a "${RESULT_FILE}"
else
    echo "make hello.c FAILED" | tee -a "${RESULT_FILE}"
fi
insmod hello.ko
rmmod hello.ko
make clean
dmesg | tail -2 | tee text.log
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
