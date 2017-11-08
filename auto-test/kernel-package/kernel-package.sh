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
    debian|ubuntu)
        package_list = "libcpupower1_4.12.0.estuary.500-1 libcpupower-dev_4.12.0.estuary.500-1 libusbip-dev_2.0+4.12.0.estuary.500-1 linux-cpupower_4.12.0.estuary.500-1 linux-estuary-doc_4.12+500 linux-estuary-perf_4.12+500 linux-estuary-source_4.12+500 linux-headers-4.12.0-500-all_4.12.0.estuary.500-1 linux-headers-4.12.0-500-all-arm64_4.12.0.estuary.500-1 linux-headers-4.12.0-500-arm64_4.12.0.estuary.500-1 linux-headers-4.12.0-500-common_4.12.0.estuary.500-1 linux-headers-estuary-arm64_4.12+500 linux-kbuild-4.12_4.12.0.estuary.500-1 linux-libc-dev_4.12.0.estuary.500-1 linux-perf-4.12_4.12.0.estuary.500-1 linux-source-4.12_4.12.0.estuary.500-1 linux-support-4.12.0-500_4.12.0.estuary.500-1 usbip_2.0+4.12.0.estuary.500-1"
        for p in package_list;do
            echo "$p install"
            apt-get install -y $p
            status=$?
            if test $status -eq 0
            then
                echo "$p install  [PASS]" | tee ${RESULT_FILE}
            else
                echo "$p install [FAIL]"  | tee ${RESULT_FILE}
            fi
            echo "$p remove"
            apt-get remove -y $p
            status=$?
            if test $status -eq 0
            then
                echo "$p remove  [PASS]" | tee ${RESULT_FILE}
            else
                echo "$p remove [FAIL]"  | tee ${RESULT_FILE}
            fi
        done
        ;;
    centos) 
        package_list = "kernel-devel-4.12.0-estuary.1 kernel-headers-4.12.0-estuary.1 kernel-tools-4.12.0-estuary.1 kernel-tools-libs-4.12.0-estuary.1 kernel-tools-libs-devel-4.12.0-estuary.1 perf-4.12.0-estuary.1 python-perf-4.12.0-estuary.1"
        for p in package_list;do
            echo "$p install"
            yum install -y $p
            status=$?
            if test $status -eq 0
            then
                echo "$p install  [PASS]" | tee ${RESULT_FILE}
            else
                echo "$p install [FAIL]"  | tee ${RESULT_FILE}
            fi
            echo "$p remove"
            yum remove -y $p
            status=$?
            if test $status -eq 0
            then
                echo "$p remove  [PASS]" | tee ${RESULT_FILE}
            else
                echo "$p remove [FAIL]"  | tee ${RESULT_FILE}
            fi
        done
        ;;
esac
