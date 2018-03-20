#!/bin/bash
. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/libbson.txt"
LOGFILE="${OUTPUT}/compilation.txt"
export RESULT_FILE
pkgcf="https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz"
install_pkg-config(){
    wget ${pkgcf}
    tar xzf pkg-config-0.29.2.tar.gz
    cd pkg-config-0.29.2
    ./configure --with-internal-glib
    cd ${OUTPUT} 
}
usage() {
    echo "Usage: $0  [-s true|false]" 1>&2
    exit 1
}

while getopts "s:h" o; do
    case "$o" in
        s) SKIP_INSTALL="${OPTARG}" ;;
        h|*) usage ;;
    esac
done
! check_root && error_msg "You need to be root to install packages!"
create_out_dir "${OUTPUT}"
cd "${OUTPUT}"
dist_name
case "${dist}" in
    centos) 
            version="1.6.2"
            SOURCE="Estuary"
            pkgs="libbson libbson-devel"
            install_deps "${pkgs}" "${SKIP_INSTALL}"
            print_info $? install-libbson-devel
            print_info $? install-libbson
            v=$(yum info libbson | grep "^Version" | awk '{print $3}')
            if [ $v = ${version} ];then
                echo "libbson version is $v: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "libbson version is $v: [FAIL]" | tee -a "${RESULT_FILE}"
            fi
            print_info $? libbson-version
            s=$(yum info libbson | grep "^From repo" | awk '{print $4}')
            if [ $s = ${SOURCE} ];then
                echo "libbson source is $s: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "libbson source is $s: [FAIL]" | tee -a "${RESULT_FILE}"
            fi
            print_info $? libbson-source

            v=$(yum info libbson-devel | grep "^Version" | awk '{print $3}')
            if [ $v = ${version} ];then
                echo "libbson-devel version is $v: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "libbson-devel version is $v: [FAIL]" | tee -a "${RESULT_FILE}"
            fi
            print_info $? libbson-dever-version
            s=$(yum info libbson-devel | grep "^From repo" | awk '{print $4}')
            if [ $s = ${SOURCE} ];then
                echo "libbson-devel source is $s: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "libbson-devel source is $s: [FAIL]" | tee -a "${RESULT_FILE}"
            fi
            print_info $? libbson-devel-source
            ;;
esac
install_pkg-config
print_info $? install-pkg-config
cp ../hello_bson.c .
gcc -o hello_bson hello_bson.c $(pkg-config --cflags --libs libbson-1.0 ) | tee "${LOGFILE}"
print_info $? complie-cpp
command="./hello_bson | grep  'bson'"
skip_list="execute_binary"
run_test_case "${command}" "${skip_list}"
print_info $? run-bson
remove_pkg "${pkgs}"
print_info $? remove-bson
rm -rf pkg-config-0.29.2
print_info $? remove-pkg
