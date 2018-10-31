#!/bin/bash

# shellcheck disable=SC1091
cd ../../../../utils
    .        ./sys_info.sh
    .        ./sh-test-lib
cd -
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE

usage() {
    echo "Usage: $0 [-s <true|false>]" 1>&2
    exit 1
}

while getopts "s:h" o; do
  case "$o" in
    s) SKIP_INSTALL="${OPTARG}" ;;
    h|*) usage ;;
  esac
done

install() {
    # shellcheck disable=SC2154
    case "${distro}" in
      debian|ubuntu) install_deps "lsb-release sysstat numactl lsof pciutils usbutils dmidecode" "${SKIP_INSTALL}"
      print_info $? install-pkg
      ;;
      fedora|centos|opensuse) install_deps "lshw lsof pcp-import-iostat2pcp redhat-lsb-core numactl pciutils usbutils sysstat dmidecode" "${SKIP_INSTALL}"
      print_info $? install-pkg
;;
      unknown) warn_msg "Unsupported distro: package install skipped" ;;
    esac
}

run() {
    # shellcheck disable=SC2039
    local test="$1"
    test_case_id="$(echo "${test}" | awk '{print $1}')"
    echo
    info_msg "Running ${test_case_id} test..."
    eval "${test}"
    check_return "${test_case_id}"
}

# Test run.
create_out_dir "${OUTPUT}"

install
run "pwd" 
print_info $? pwd

run "lsb_release -a"
print_info $? lsb_release

run "uname -a"
print_info $? uname

run "ip a"
print_info $? ip a

run "lscpu"
print_info $? lscpu

run "vmstat"
print_info $? vmstat

run "lsblk"
print_info $? lsblk

run "dmesg"
print_info $? dmesg

run "lspci -vv"
print_info $? lspci

run "dmidecode"
print_info $? dmidecode

run "lsusb"
print_info $? lsusb

run "lsmod"
print_info $? lsmod

run "numactl --hardware"
print_info $? numactl

run "cat /proc/cpuinfo"
print_info $? cpuinfo

run "cat /proc/meminfo"
print_info $? meminfo

run "ps -el"
print_info $? ps

run "cat /proc/interrupts"
print_info $? interrupts

run "echo $PATH"
print_info $? PATH

run "cat /proc/cmdline"
print_info $? cmdline

run "cat /proc/devices"
print_info $? devices

run "cat /proc/filesystems"
print_info $? filesystems

run "echo $env"
print_info $? env

run "timedatectl"
print_info $? timedatectl

run "free"
print_info $? free

run "numastat"
print_info $? numastat

run "iostat"
print_info $? iostat

#run "lshw"
#print_info $? lshw

run "lsof"
print_info $? lsof

