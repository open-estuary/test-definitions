#!/bin/bash

. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
kernel_name = "kernel-aarch64-4.12.0-estuary.1"
dist_name
case "${dist}" in
    debian|ubuntu)
        echo "not surpport"        
        ;;
    centos) 
        yum install yum-utils
        yum-builddep -y kernel
        yum install -y pesign
        yumdownloader --source kernel
        rpmbuild --rebuild  ${kernel_name} | tee  "${RESULT_FILE}"
        status=$?
        if test $status -eq 0
        then
            echo "rpmbuild   [PASS]"
        else
            echo "rmpbuild [FAIL]"
            exit
        fi
        ;;
esac
