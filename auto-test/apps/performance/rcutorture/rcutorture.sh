#!/bin/bash 
#RCU or Read-Copy Update Torture test for Linux Kernel.

source ../../../../utils/sys_info.sh
source ../../../../utils/sh-test-lib

#test user id
! check_root && error_msg "Please run this script as root."

#environment preparation
pkgs="gzip"
install_deps ${pkgs}
info_msg "install-$pkgs successfully"

#set variable
TORTURE_TIME="600"

# procedure

# Check kernel config.
if [ -f "/proc/config.gz" ]; then
    test_cmd="gunzip -c /proc/config.gz | grep CONFIG_RCU_TORTURE_TEST=m"
elif [ -f "/boot/config-$(uname -r)" ]; then
    test_cmd="grep CONFIG_RCU_TORTURE_TEST=m /boot/config-$(uname -r)"
fi
eval $test_cmd
print_info $? check-kernel-config

# Insert rcutoruture kernel module.
dmesg -c > /dev/null
if lsmod | grep rcutorture; then
    rmmod rcutorture || true
fi
modprobe rcutorture
print_info $? modprobe-rcutorture

# Check if rcutoruture started.
sleep 10
dmesg | grep 'rcu-torture:--- Start of test'
print_info $? rcutorture-start

info_msg "Running rcutorture for ${TORTURE_TIME} seconds..."
sleep "${TORTURE_TIME}"

# Remove rcutoruture kernel module.
rmmod rcutorture
print_info $? rmmod-rcutorture

# Check if rcutoruture test finished successfully.
sleep 10
dmesg > dmesg-rcutorture.txt
if grep 'rcu-torture:--- End of test: SUCCESS' dmesg-rcutorture.txt; then
    print_info 0 rcutorture-end
else
    print_info 1 rcutorture-end
fi

remove_deps "gzip"
info_msg "remove pkgs successfully"
