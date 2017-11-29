#!/bin/bash

. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
LOG="${OUTPUT}/log.txt"
export RESULT_FILE
kernel_name=""
dist_name
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"
headers=$(uname -r)
case "${dist}" in
    ubuntu)
        kernel_name="linux-image-${headers}"
        sudo apt-get build-dep ${kernel_name} | tee "${LOG}"
        sudo apt-get source -b ${kernel_name} | tee "${LOG}"
        status=$?
        if test $status -eq 0
        then
            echo "rpmbuild [PASS]" | tee -a ${RESULT_FILE}
        else
            echo "rmpbuild [FAIL]" | tee -a ${RESULT_FILE}
        fi
        ;;
    debian)
        kernel_name="linux-image-${headers}"
        apt-get build-dep ${kernel_name} | tee "${LOG}"
        apt-get source -b ${kernel_name} | tee "${LOG}"
        status=$?
        if test $status -eq 0
        then
            echo "rpmbuild [PASS]" | tee -a ${RESULT_FILE}
        else
            echo "rmpbuild [FAIL]" | tee -a ${RESULT_FILE}
        fi
        ;;
    centos) 
        kernel_name="kernel-aarch64-4.12.0-estuary.2"
        yum install yum-utils
        yum-builddep -y kernel
        yum install -y pesign
        yumdownloader --source kernel
        rpmbuild --rebuild  ${kernel_name} | tee  "${LOG}"
        status=$?
        if test $status -eq 0
        then
            echo "rpmbuild  [PASS]" | tee -a "${RESULT_FILE}"
        else
            echo "rmpbuild [FAIL]" | tee -a "${RESULT_FILE}"
        fi
        ;;
esac
