#!/bin/bash

. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
package_list = ""
dist_name
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"
case "${dist}" in
    debian)
        package_list="libcpupower1 libcpupower-dev libusbip-dev linux-cpupower linux-estuary-doc linux-estuary-perf  linux-estuary-source linux-headers-4.12.0-500-all linux-headers-4.12.0-500-all-arm64 linux-headers-4.12.0-500-arm64 linux-headers-4.12.0-500-common linux-headers-estuary-arm64 linux-kbuild-4.12 linux-libc-dev linux-perf-4.12 linux-source-4.12 linux-support-4.12.0-500 usbip"
        for p in ${package_list};do
            echo "$p install"
            apt-get install -y $p
            status=$?
            if test $status -eq 0
            then
                echo "$p install  [PASS]" | tee -a ${RESULT_FILE}
            else
                echo "$p install [FAIL]"  | tee -a ${RESULT_FILE}
            fi
            echo "$p remove"
            apt-get remove -y $p
            status=$?
            if test $status -eq 0
            then
                echo "$p remove  [PASS]" | tee -a ${RESULT_FILE}
            else
                echo "$p remove [FAIL]"  | tee -a ${RESULT_FILE}
            fi
        done
        ;;
    centos) 
        package_list = "kernel-devel-4.12.0-estuary.1 kernel-headers-4.12.0-estuary.1 kernel-tools-4.12.0-estuary.1 kernel-tools-libs-4.12.0-estuary.1 kernel-tools-libs-devel-4.12.0-estuary.1 perf-4.12.0-estuary.1 python-perf-4.12.0-estuary.1"
        for p in ${package_list};do
            echo "$p install"
            yum install -y $p
            status=$?
            if test $status -eq 0
            then
                echo "$p install  [PASS]" | tee -a ${RESULT_FILE}
            else
                echo "$p install [FAIL]"  | tee -a ${RESULT_FILE}
            fi
            echo "$p remove"
            yum remove -y $p
            status=$?
            if test $status -eq 0
            then
                echo "$p remove  [PASS]" | tee -a ${RESULT_FILE}
            else
                echo "$p remove [FAIL]"  | tee -a ${RESULT_FILE}
            fi
        done
        ;;
esac
