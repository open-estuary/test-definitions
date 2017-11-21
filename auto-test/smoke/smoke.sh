#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
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
    dist_name
    # shellcheck disable=SC2154
    case "${dist}" in
      debian|ubuntu) install_deps "lsb-release" "${SKIP_INSTALL}";;
      fedora|centos) install_deps "redhat-lsb-core numactl usbutils" "${SKIP_INSTALL}";;
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
run "lsb_release -a"
run "uname -a"
run "ip a"
run "lscpu"
run "vmstat"
run "lsblk"
run "dmesg"
run "lspci -vv"
run "dmidecode"
run "lsusb"
run "lsmod"
run "numactl --hardware"
run "cat /proc/cpuinfo "
run "cat /proc/meminfo "
run "ps -el"
run "cat /proc/interrupts"
run "echo $PATH"
run "cat /proc/cmdline"
run "cat /proc/devices"
run "cat /proc/filesystems"
run "echo $env"
run "date"
run "free"
run "numastat"
run "iostat"
run "lshw"
run "lsof"
run "ls -l /sys/class/i2c-dev/*/device/firmware_node | grep HISI"
