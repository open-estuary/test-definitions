#!/bin/bash
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
LOG_FILE="${OUTPUT}/sysstat.txt"
ITERATION="30"
PARTITION=""

usage() {
    echo "Usage: $0 [-s <true|flase>] [-t <true|flase>]" 1>&2
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
      centos) install_deps "sysstat" "${SKIP_INSTALL}" ;;
      unknown) warn_msg "Unsupported distro: package install skipped" ;;
    esac
}
sysstat_test() {
    /usr/lib64/sa/sadc  1 10 sa000
    sar -f sa000 | tee -a ${RESULT_FILE}
    sar -u  1 5 | tee -a ${RESULT_FILE}
    sar -n DEV 2 5 | tee -a ${RESULT_FILE}
    iostat -x | tee -a  ${RESULT_FILE}
    mpstat 2 10 | tee -a ${RESULT_FILE}
}
! check_root && error_msg "You need to be root to run this script."
create_out_dir "${OUTPUT}"
cd "${OUTPUT}"

install
sysstat_test
