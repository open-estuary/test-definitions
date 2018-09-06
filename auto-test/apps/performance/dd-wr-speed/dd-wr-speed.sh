#!/bin/bash 
# Copyright (C) 2018-8-29, Linaro Limited.
# Author: wangsisi

# shellcheck disable=SC1091
source ../../../../utils/sys_info.sh
source ../../../../utils/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
ITERATION="5"

dd_write() {
    echo
    echo "--- dd write speed test ---"
    rm -f dd-write-output.txt
    for i in $(seq "${ITERATION}"); do
        echo "Running iteration ${i}..."
        rm -f dd.img
#清理系统缓存
        echo 3 > /proc/sys/vm/drop_caches
#zero设备中创建一个（bs决定每次读写1048576字节，count定义读写次数为1024次）但内容全为0的文件
        dd if=/dev/zero of=dd.img bs=1048576 count=1024 conv=fsync 2>&1 \
            | tee  -a "${OUTPUT}"/dd-write-output.txt
    done
}

dd_read() {
    echo
    echo "--- dd read speed test ---"
    rm -f dd-read-output.txt
    for i in $(seq "${ITERATION}"); do
        echo "Running iteration ${i}..."
        echo 3 > /proc/sys/vm/drop_caches
        dd if=dd.img of=/dev/null bs=1048576 count=1024 2>&1 \
            | tee -a "${OUTPUT}"/dd-read-output.txt
    done
    rm -f dd.img
}

parse_output() {
    test_case_id="$1"
    if ! [ -f "${OUTPUT}/${test_case_id}-output.txt" ]; then
        warn_msg "${test_case_id} output file is missing"
        return 1
    fi

    itr=1
    while read -r line; do
        if echo "${line}" | egrep -q "(M|G)B/s"; then
            measurement="$(echo "${line}" | awk '{print $(NF-1)}')"
            units="$(echo "${line}" | awk '{print substr($NF,1,2)}')"
            result=$(convert_to_mb "${measurement}" "${units}")

            add_metric "${test_case_id}-itr${itr}" "pass" "${result}" "MB/s"
            itr=$(( itr + 1 ))
        fi
    done < "${OUTPUT}/${test_case_id}-output.txt"

    # For mutiple times dd test, calculate the mean, min and max values.
    # Save them to result.txt.
    if [ "${ITERATION}" -gt 1 ]; then
        eval "$(grep "${test_case_id}" "${OUTPUT}"/result.txt \
            | awk '{
                       if(min=="") {min=max=$3};
                       if($3>max) {max=$3};
                       if($3< min) {min=$3};
                       total+=$3; count+=1;
                   }
               END {
                       print "mean="total/count, "min="min, "max="max;
                   }')"

        # shellcheck disable=SC2154
        add_metric "${test_case_id}-mean"  "pass" "${mean}" "MB/s"
        # shellcheck disable=SC2154
        add_metric "${test_case_id}-min" "pass" "${min}" "MB/s"
        # shellcheck disable=SC2154
        add_metric "${test_case_id}-max" "pass" "${max}" "MB/s"
    fi
}

# Test run.
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"

info_msg "About to run dd test..."
info_msg "Output directory: ${OUTPUT}"

pkgs="e2fsprogs dosfstools"
install_deps "${pkgs}" "${SKIP_INSTALL}"
if test $? -eq 0;then
    info_msg "install  pass"
else
    info_msg "install fail"
fi

info_msg "dd test directory: $(pwd)"
dd_write
parse_output "dd-write"
print_info $? dd-write
dd_read
parse_output "dd-read"
print_info $? dd-read
