#!/bin/sh 

if [ `whoami` != "root" ];then
        echo "YOu must be the root to run this script" >$2
        exit 1
fi

set -x
. ../../../../utils/sys_info.sh
. ../../../../utils/sh-test-lib

ITERATION="30"
PARTITION=""


# Set the directory for blogbench test.
if [ -n "${PARTITION}" ]; then
    if mount | grep -q "${PARTITION}"; then
        mount "${PARTITION}" /mnt
        cd /mnt/
    else
        mount_point=$(mount | grep "${PARTITION}" | awk '{print $3}')
        cd "${mount_point}"
    fi
fi
print_info $? mount-directory
mkdir ./bench

# Run blogbench test.
detect_abi
# shellcheck disable=SC2154
./bin/"${abi}"/blogbench -i "${ITERATION}" -d ./bench 2>&1 | tee blogbench_log.txt
print_info $? test-blogbench
# Parse test result.
for i in writes reads; do
    grep "Final score for $i" log.txt \
        | awk -v i="$i" '{printf("blogbench-%s pass %s blogs\n", i, $NF)}' \
        | tee -a blogbench_result.txt
done

rm -rf ./bench
print_info $? delete-blogbench
