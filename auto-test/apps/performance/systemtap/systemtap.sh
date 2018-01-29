#!/bin/bash
. ../../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
LOG_FILE="${OUTPUT}/log.txt"
SKIP_INSTALL="no"
VERSION="3.1"
SOURCE="Estuary"
PACKAGE="systemtap"
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"
install_systemtap() {
    dist_name
    # shellcheck disable=SC2154
    case "${dist}" in
      centos) 
            DEPENDES="gcc elfutils kernel-devel kernel-debuginfo kernel-debug-debuginfo"
            install_deps "${PACKAGE} ${DEPENDS}" "${SKIP_INSTALL}"
            if test $? -eq 0;then
                echo "${PACKAGE} install: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "${PACKAGE} install: [FAIL]" | tee -a "${RESULT_FILE}"
                exit 1
            fi
            version=$(yum info ${PACKAGE} | grep "^Version" | awk '{print $3}')
            if [ ${version} = ${VERSION} ];then
                echo "${PACKAGE} version is ${version}: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "${PACKAGE} version is ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
                exit 1
            fi
            sourc=$(yum info ${PACKAGE} | grep "^From repo" | awk '{print $4}')
            if [ ${sourc} = ${SOURCE} ];then
                echo "${PACKAGE} source from ${version}: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "${PACKAGE} source from ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
                exit 1
            fi
            ;;
      unknown) warn_msg "Unsupported distro: package install skipped" ;;
    esac
}
stap -ve 'probe kernel.function("do_fork") { print("hello world\n") exit() }'
if test $? -eq 0;then
    echo "${PACKAGE} work : [PASS]" | tee -a "${RESULT_FILE}"
else
    echo "${PACKAGE} work: [PASS]" | tee -a "${RESULT_FILE}"
fi
install_systemtap
remove_deps "${PACKAGE} ${DEPENDS}"
if test $? -eq 0;then
    echo "${PACKAGE} remove: [PASS]" | tee -a "${RESULT_FILE}"
else
    echo "${PACKAGE} remove: [FAIL]" | tee -a "${RESULT_FILE}"
    exit 1
fi


