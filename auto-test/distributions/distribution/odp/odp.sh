#!/bin/bash
. ../../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
LOG_FILE="${OUTPUT}/log.txt"
SKIP_INSTALL="no"
url="git://git.linaro.org/lng/odp.git"
PACKAGE="git build-essential automake autoconf libtool libssl-dev libcunit1-dev"
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"
install_odp() {
    dist_name
    # shellcheck disable=SC2154
    case "${dist}" in
      centos | debian) 
            install_deps "${PACKAGE}" "${SKIP_INSTALL}"
            if test $? -eq 0;then
                echo "${PACKAGE} install: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "${PACKAGE} install: [FAIL]" | tee -a "${RESULT_FILE}"
                exit 1
            fi
            git clone ${url}
            if test $? -eq 0;then
                echo "odp  download: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "odp download: [FAIL]" | tee -a "${RESULT_FILE}"
            fi
            cd odp
            ./bootstrap
            autoreconf -i
            ./configure --enable-test-vald --with-testdir=/usr/lib/odp/ptest/test
            make install
            ./usr/lib/odp/ptest/test/run-test >> "${RESULT_FILE}"
            ;;
      unknown) 
            warn_msg "Unsupported distro: package install skipped" 
            exit 1
            ;;
    esac
}
install_odp
remove_deps "${PACKAGE}"
if test $? -eq 0;then
    echo "${PACKAGE} remove: [PASS]" | tee -a "${RESULT_FILE}"
else
    echo "${PACKAGE} remove: [FAIL]" | tee -a "${RESULT_FILE}"
    exit 1
fi
