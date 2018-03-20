#!/bin/bash
. ../../../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
LOG_FILE="${OUTPUT}/log.txt"
SKIP_INSTALL="no"
VERSION="3.1.8"
SOURCE="Estuary"
PACKAGE="source-highlight"
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"
install_source-highlight() {
    dist_name
    # shellcheck disable=SC2154
    case "${dist}" in
      centos) 
            install_deps "${PACKAGE}" "${SKIP_INSTALL}"
            if test $? -eq 0;then
                 print_info 0 install
            else
                print_info 1 install
                exit 1
            fi
            version=$(yum info ${PACKAGE} | grep "^Version" | awk '{print $3}')
            if [ ${version} = ${VERSION} ];then
                 print_info 0 version
            else
                 print_info 1 version
                exit 1
            fi
            sourc=$(yum info ${PACKAGE} | grep "^From repo" | awk '{print $4}')
            if [ ${sourc} = ${SOURCE} ];then
                  print_info 0 repo_check
            else
                 print_info 1 repo_check
                exit 1
            fi
            ;;
      unknown) warn_msg "Unsupported distro: package install skipped" ;;
    esac
}
install_source-highlight
remove_deps "${PACKAGE}"
if test $? -eq 0;then
     print_info 0 remove
else
    print_info 1 remove
    exit 1
fi


