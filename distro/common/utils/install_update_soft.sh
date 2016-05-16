#!/bin/bash
set -x

update_commands=$1
indtall_commands=$2
softwares=$3
log_file=$4
distro=$5

$update_commands | tee ${log_file}
if [ $? -eq 0 ]; then
    echo "update-software in $distro success" | tee ${log_file}
    lava-test-case update-software-of-${distro} --result pass
else
    echo "update-software in $distro fail" | tee ${log_file}
    lava-test-case update-software-of-${distro} --result fail
    echo -1
fi

$install_commands $softwares | tee ${log_file}
if [ $? -eq 0 ]; then
    echo "install-software in $distro success" | tee ${log_file}
    lava-test-case install-software-of-${distro} --result pass
else
    echo "install-software in $distro fail" | tee ${log_file}
    lava-test-case install-software-of-${distro} --result fail
    echo -1
fi
