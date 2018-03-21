#!/bin/bash
. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
LOG_FILE="${OUTPUT}/sysstat.txt"
ITERATION="30"
PARTITION=""
VERSION="11.5.5"
SOURCE="Estuary"
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
      centos) 
            install_deps "sysstat" "${SKIP_INSTALL}"
            if test $? -eq 0;then
                echo "sysstat install: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "sysstat install: [FAIL]" | tee -a "${RESULT_FILE}"
                exit 1
            fi
            print_info $? install-pkgs
            version=$(yum info sysstat | grep "^Version" | awk '{print $3}')
            if [ ${version} = ${VERSION} ];then
                echo "syssta version is ${version}: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "syssta version is ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
                #exit 1
            fi
            print_info $? sys-version
            sourc=$(yum info sysstat | grep "^From repo" | awk '{print $4}')
            if [ ${sourc} = ${SOURCE} ];then
                echo "syssta source from ${version}: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "syssta source from ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
                #exit 1
            fi
            print_info $? sys-source
            ;;
      unknown) warn_msg "Unsupported distro: package install skipped" ;;
    esac
}
sysstat_test() {
    /usr/lib64/sa/sadc  1 10 sa000
    print_info $? sadc-test
    sar -f sa000 | tee -a ${LOG_FILE}
    print_info $? sar-cpu
    sar -u  1 5 | tee -a ${LOG_FILE}
    print_info $? sar-network
    sar -n DEV 2 5 | tee -a ${LOG_FILE}
    print_info $? sar-io
    iostat -x | tee -a  ${LOG_FILE}
    print_info $? iostat-test
    mpstat 2 10 | tee -a ${LOG_FILE}
    print_info $? mpstat-test
}
! check_root && error_msg "You need to be root to run this script."
create_out_dir "${OUTPUT}"
cd "${OUTPUT}"

install
sysstat_test
remove_deps "sysstat"
print_info $? remove-sysstat
