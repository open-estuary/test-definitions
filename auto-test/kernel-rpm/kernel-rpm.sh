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
cd ${OUTPUT}
headers=$(uname -r)
case "${dist}" in
    ubuntu)
        kernel_name="linux-image-${headers}"
        sudo apt-get build-dep ${kernel_name} | tee "${LOG}"
        status=$?
        if test $status -eq 0;then
            echo "内核编译依赖安装: [PASS]" | tee -a ${RESULT_FILE}
        else
            echo "内核编译依赖安装: [FIAL]" | tee -a ${RESULT_FILE}
        fi
        sudo apt-get source -b ${kernel_name} | tee "${LOG}"
        status=$?
        if test $status -eq 0
        then
            echo "deb package build [PASS]" | tee -a ${RESULT_FILE}
        else
            echo "deb package build [FAIL]" | tee -a ${RESULT_FILE}
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
        yum install yum-utils
        yum build-dep -y kernel
        yum install -y pesign
        yum install rpm-build
        yumdownloader --source kernel
        status=$?
        if test $status -eq 0
        then
            echo "source rpm download: [PASS]" | tee -a "${RESULT_FILE}"
        else
            echo "source rpm download: [FAIL]" | tee -a "${RESULT_FILE}"
        fi
        kernel_name=$(ls | grep "kernel-aarch64-")
        rpmbuild --rebuild  ${kernel_name} | tee  "${LOG}"
        status=$?
        if test $status -eq 0
        then
            echo "rpmbuild [PASS]" | tee -a "${RESULT_FILE}"
        else
            echo "rmpbuild [FAIL]" | tee -a "${RESULT_FILE}"
        fi
        ;;
esac
cd -
