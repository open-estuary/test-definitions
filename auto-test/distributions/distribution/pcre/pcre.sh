#!/bin/bash
. ../../../../lib/sh-test-lib
. ../../../../utils/sys_info.sh
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
LOG_FILE="${OUTPUT}/log.txt"
SKIP_INSTALL="no"
VERSION="8.41"
SOURCE="Estuary"
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"
install_pcre() {
    dist_name
    # shellcheck disable=SC2154
    case "${dist}" in
      centos)
            install_deps "pcre gcc-c++" "${SKIP_INSTALL}"
            if test $? -eq 0;then
                echo "pcre install: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "pcre install: [FAIL]" | tee -a "${RESULT_FILE}"
                exit 1
            fi
            print_info $? install-pcre
            version=$(yum info pcre | grep "^Version" | awk '{print $3}')
            if [ ${version} = ${VERSION} ];then
                echo "pcre version is ${version}: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "pcre version is ${version}: [FAIL]" | tee -a "${RESULT_FILE}"

            fi
            print_info $? pcre-version
            sourc=$(yum info pcre | grep "^From repo" | awk '{print $4}')
            if [ ${sourc} = ${SOURCE} ];then
                echo "pcre source from ${version}: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "pcre source from ${version}: [FAIL]" | tee -a "${RESULT_FILE}"

             fi
             print_info $? pcre-source
            ;;
      unknown) warn_msg "Unsupported distro: package install skipped" ;;
    esac
}
install_pcre
g++ -o pcre test_pcre.cpp -lpcre
if test $? -eq 0;then
    echo "pcre build: [PASS]" | tee -a "${RESULT_FILE}"
    print_info $? compilation-cpp
else
    echo "pcre build: [FAIL]" | tee -a "${RESULT_FILE}"
fi
./pcre | tee -a "${LOG_FILE}"
print_info $? run-cpp
 cat ${LOG_FILE} | grep "PCRE compilation pass"

 if [ $? -eq 0 ];then
    echo "regular-compilation: [PASS]" | tee -a ${RESULT_FILE}
    print_info $? regular-comilation
else
    echo "regular-compilation: [FIAL]" | tee -a ${RESULT_FILE}
fi
#if [ cat ${LOG_FILE} | grep "OK, has matched" ];then
 cat ${LOG_FILE} | grep "OK, has matched"
 if [ $? -eq 0 ];then
    echo "regular-matches: [PASS]" | tee -a ${RESULT_FILE}
    print_info $? regular-matches
else
    echo "regular-matches: [FIAL]" | tee -a ${RESULT_FILE}
fi
 cat ${LOG_FILE} | grep "free ok"
 if [ $? -eq 0 ];then
    echo "regular-release: [PASS]" | tee -a ${RESULT_FILE}
    print_info $? regular-release
else
    echo "regular-release: [FIAL]" | tee -a ${RESULT_FILE}
fi
case $distro in
    "centos")
        yum remove  gcc-c++ -y
        print_info $? remove-pcre
        ;;
esac
