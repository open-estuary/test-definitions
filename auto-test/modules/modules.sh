#!/bin/bash

. ../../lib/sh-test-lib
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
        apt-get install linux-source-${headers}
        status=$?
        if [ $status -eq 0 ];then
            echo "linux-source-${headers} install : PASS" | tee -a "${RESULT_FILE}"
        else
            echo "linux-source-${headers} install : FAILED" | tee -a "${RESULT_FILE}"
        fi
        
        apt-get install -y linux-headers-${headers}
        status=$?
        if [ $status -eq 0 ];then
            echo "linux-headers install : PASS" | tee -a "${RESULT_FILE}"
        else
            echo "linux-headers install : FAILED" | tee -a "${RESULT_FILE}"
        fi
        apt-get install -y make
        apt-get install -y gcc
        ;;
    centos)
        yum install -y kernel-headers-${headers}
        status=$?
        if [ $status -eq 0 ];then
            echo "kernel-headers-${headers} install : PASS" | tee -a "${RESULT_FILE}"
        else
            echo "kernel-heasers-${headers} install : FAILED" | tee -a "${RESULT_FILE}"
        fi
        #yumdownloader --source kernel 
        yum install -y kernel-devel
        status=$?
        if [ $status -eq 0 ];then
            echo "kernel-aarch64-${headers} download : PASS" | tee -a "${RESULT_FILE}"
        else
            echo "kernel-aarch64-${headers} download : FAILED" | tee -a "${RESULT_FILE}"
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
    echo "make source file PASS" | tee -a "${RESULT_FILE}"
else
    echo "make source FAILED" | tee -a "${RESULT_FILE}"
fi
insmod hello.ko 
dmesg | tail -2 | tee -a "${LOG}"
cat "${LOG}" | grep Hello
status=$?
if [ $status -eq 0 ];then
    echo "insmod KO PASS" | tee -a "${RESULT_FILE}"
else
    echo "insmod KO FAILED" | tee -a "${RESULT_FILE}"
fi
rmmod hello.ko
dmesg | tail -2 | tee -a "${LOG}"
cat "${LOG}" | grep Goodbye
status=$?
if [ $status -eq 0 ];then
    echo "rmmod PASS" | tee -a "${RESULT_FILE}"
else
    echo "rmmod FAILED" | tee -a "${RESULT_FILE}"
fi
make clean | tee -a "${LOG}"
