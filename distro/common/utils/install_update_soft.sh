#!/bin/bash

update_commands=$1
softwares=$2
log_file=$3
distro=$4

$update_commands | tee ${log_file}
if [ $? -ne 0 ]; then
    echo "update-software in $distro success" | tee ${log_file}
    lava-test-case update-software-of-${distro} --result pass
else
    echo "update-software in $distro fail" | tee ${log_file}
    lava-test-case update-software-of-${distro} --result fail
    echo -1
fi

$install_commands $softwares | tee ${log_file}
if [ $? -ne 0 ]; then
    echo "install-software in $distro fail" | tee ${log_file}
    lava-test-case install-software-of-${distro} --result fail
else
    echo "install-software in $distro fail" | tee ${log_file}
    lava-test-case install-software-of-${distro} --result fail
    echo -1
fi
