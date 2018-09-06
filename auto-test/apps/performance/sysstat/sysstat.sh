#!/bin/bash

. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh

#检查root
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

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
        "ubuntu"|"debian"|"opensuse")
            pkgs="sysstat"
            install_deps "${pkgs}"
            print_info $? install-sysstat
            ;;
        "fedora")
           pkgs="sysstat.aarch64"
           install_deps "${pkgs}"
           print_info $? install-sysstat
           ;;
      unknown) warn_msg "Unsupported distro: package install skipped" ;;
    esac
}
sysstat_test() {
#收集1秒之内的10次动态信息到指定文件
    /usr/lib64/sa/sadc  1 10 sa00
#通过sar工具查看系统状态
    sar -f sa000 | tee -a ${LOG_FILE}
    print_info $? sar-cpu
   
#查看CPU利用率，每秒更新一次，更新5次
    sar -u  1 5 | tee -a ${LOG_FILE}
    print_info $? sar-network

#查看设备的情况
    sar -n DEV 2 5 | tee -a ${LOG_FILE}
    print_info $? sar-io

#查看io设备的情况
    iostat -x | tee -a  ${LOG_FILE}
    print_info $? iostat-test

#获取CPU的信息，2秒运行一次，运行10次
    mpstat 2 10 | tee -a ${LOG_FILE}
    print_info $? mpstat-test
}

install
sysstat_test
case $distro in
      "centos")
       remove_deps "sysstat"
       print_info $? remove-sysstat
       ;;
      "ubuntu"|"opensuse"|"fedora"|"debian")
       remove_deps "${pkgs}"
       print_info $? remove-sysstat
       ;;

esac
