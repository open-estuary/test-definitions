#!/bin/bash

# shellcheck disable=SC1091
. ../../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT="$(readlink -f "${0}")"
# Absolute path this script is in. /home/user/bin
SCRIPTPATH="$(dirname "${SCRIPT}")"
echo "Script path is: ${SCRIPTPATH}"
# List of test cases
TST_CMDFILES=""
# List of test cases to be skipped
SKIPFILE=""
# LTP version
LTP_VERSION="20170516"

LTP_PATH=/opt/ltp

usage() {
    echo "Usage: ${0} [-T mm,math,syscalls]
                      [-S skipfile-lsk-juno]
                      [-s True|False]
                      [-v LTP_VERSION]
                      [-M Timeout_Multiplier]
                      [-R root_password]" 1>&2
    exit 0
}

while getopts "M:T:S:s:v:R:" arg; do
   case "$arg" in
     T)
        TST_CMDFILES="${OPTARG}"
        # shellcheck disable=SC2001
        LOG_FILE=$(echo "${OPTARG}"| sed 's,\/,_,')
        ;;
     S)
        OPT=$(echo "${OPTARG}" | grep "http")
        if [ -z "${OPT}" ] ; then
        # LTP skipfile
          SKIPFILE="-S ${SCRIPTPATH}/${OPTARG}"
        else
        # Download LTP skipfile from speficied URL
          wget "${OPTARG}" -O "skipfile"
          SKIPFILE="skipfile"
          SKIPFILE="-S ${SCRIPTPATH}/${SKIPFILE}"
        fi
        ;;
     # SKIP_INSTALL is true in case of Open Embedded builds
     # SKIP_INSTALL is flase in case of Debian builds
     s) SKIP_INSTALL="${OPTARG}";;
     v) LTP_VERSION="${OPTARG}";;
     # Slow machines need more timeout Default is 5min and multiply * MINUTES
     M) export LTP_TIMEOUT_MUL="${OPTARG}";;
     R) export PASSWD="${OPTARG}";;
  esac
done

# Install LTP test suite
install_ltp() {
    rm -rf /opt/ltp
    mkdir -p /opt/ltp
    # shellcheck disable=SC2164
    cd /opt/ltp
    # shellcheck disable=SC2140

    # For the purposes of the ERP 17.08 release, use an ltp branch.
    # This branch is based on the 20170516 release, plus backported fixes.
    wget -O ltp-erp-17.08.tar.gz https://api.github.com/repos/linaro/ltp/tarball/erp-17.08
    tar --strip-components=1 -zxf ltp-erp-17.08.tar.gz

    make autotools
    ./configure
    make -j8 all
    make SKIP_IDCHECK=1 install
}

# Parse LTP output
parse_ltp_output() {
    grep -E "PASS|FAIL|CONF"  "$1" | awk '{print $1" "$2}' | sed s/CONF/SKIP/  >> "${RESULT_FILE}"
}

# Run LTP test suite
run_ltp() {
    # shellcheck disable=SC2164
    cd "${LTP_PATH}"
    #pipe0_status "./runltp -f commands"
    pipe0_status "./runltp -p -q -f ${TST_CMDFILES} -l ${OUTPUT}/LTP_${LOG_FILE}.log -C ${OUTPUT}/LTP_${LOG_FILE}.failed ${SKIPFILE}" "tee ${OUTPUT}/LTP_${LOG_FILE}.out"
 check_return "runltp_${LOG_FILE}"
   ./runltp -f commands 2>&1 | tee ltp.log
   print_info $? commands-test
   ./runltp -f fs_perms_simple 2>&1 | tee -a ltp.log
   print_info $? files-groups
   ./runltp -f modules 2>&1 | tee -a ltp.log
   print_info $? kernel-modules
   ./runltp -f pipes 2>&1 | tee -a ltp.log
   print_info $? ipc-pipeline
   ./runltp -f sched 2>&1 | tee -a ltp.log
   print_info $? dispatching-pressure
   ./runltp -f tracing 2>&1 |tee -a ltp.log
   print_info $? tracing-test
   ./runltp -f io 2>&1 |tee -a ltp.log
   print_info $? aio-input-output
   ./runltp -f can 2>&1 |tee -a ltp.log
   print_info $? controller-area-network
   ./runltp tpm_tools | tee -a ltp.log
   print_info $? TPM-tool
   #测试信号量
    cd testcases/open_posix_testsuite
    make
    cd bin
    ./run-posix-option-group-test.sh AIO 2>&1 | tee ltp-posix.log
    print_info $? posix-AIO
    ./run-posix-option-group-test.sh SIG 2>&1 | tee -a ltp-posix.log
    print_info $? posix-SIG
    ./run-posix-option-group-test.sh SEM 2>&1 | tee -a ltp-posix.log
    print_info $? posix-SEM
    ./run-posix-option-group-test.sh THR 2>&1 | tee -a ltp-posix.log
    print_info $? posix-THR
    ./run-posix-option-group-test.sh TMR 2>&1 | tee -a ltp-posix.log
    print_info $? posix-TMR
    ./run-posix-option-group-test.sh MSG 2>&1 | tee -a ltp-posix.log
    print_info $? posix-MSG
    ./run-posix-option-group-test.sh TPS 2>&1 | tee -a ltp-posix.log
    print_info $? posix-TPS
    ./run-posix-option-group-test.sh MEM 2>&1 | tee -a ltp-posix.log
    print_info $? posix-MEM
    cd /opt/ltp
    ./runltp ipv6_lib 2>&1 |tee -a ltp.log
    print_info $? ipv6-addr
    ./runltp multicase 2>&1 |tee -a ltp.log
    print_info $? multicast-test
    ./runltp -f nfs  2>&1 |tee -a ltp.log
    print_info $? nfs-test
    ./runltp -f net_stress.interface 2>&1 |tee -a ltp.log
    print_info $? net-interface
    ./runltp -f net_stress.ipsec_icmp 2>&1 |tee -a ltp.log
    print_info $? net-icmp
    parse_ltp_output "${OUTPUT}/LTP_${LOG_FILE}.log"
    ./runltp -f net_stress.ipsec_tcp 2>&1 |tee -a ltp.log
    print_info $? net-tcp
    ./runltp -f net_stress.ipsec_udp 2>&1 |tee -a ltp.log
    print_info $? net-udp
    cd /opt/ltp/testscripts
    ./adp.sh -d 2 -n 2 2>&1 |tee -a ltp.log
    print_info $? adp-test
}

# Test run.
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"

info_msg "About to run ltp test..."
info_msg "Output directory: ${OUTPUT}"

if [ "${SKIP_INSTALL}" = "True" ] || [ "${SKIP_INSTALL}" = "true" ]; then
    info_msg "install_ltp skipped"
else
    dist_name
    # shellcheck disable=SC2154
    case "${dist}" in
      debian|ubuntu)
        pkgs="xz-utils flex bison build-essential wget curl net-tools quota genisoimage sudo libaio-dev automake expect"
        install_deps "${pkgs}" "${SKIP_INSTALL}"
        ;;
      centos|fedora)
        pkgs="xz flex bison make automake gcc gcc-c++ kernel-devel wget curl net-tools quota genisoimage sudo libaio expect"
        install_deps "${pkgs}" "${SKIP_INSTALL}"
        ;;
      *)
        warn_msg "Unsupported distribution: package install skipped"
    esac

    # Check if mkisofs or genisoimage installed for isofs test.
    if echo "${TST_CMDFILES}" | grep 'fs'; then
        # link mkisofs to genisoimage on distributions that have replaced mkisofs with genisoimage.
        if ! which mkisofs; then
            if which genisoimage; then
                ln -s "$(which genisoimage)" /usr/bin/mkisofs
            else
                warn_msg "Neither mkisofs nor genisoimage found! Either of them is required by isofs test."
            fi
        fi
    fi

    info_msg "Run install_ltp"
    install_ltp
fi
info_msg "Running run_ltp"
run_ltp
