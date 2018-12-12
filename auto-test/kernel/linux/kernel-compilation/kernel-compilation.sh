# ====================
# Filename: kernel-compilation
# Author: 
# Email:
# Date: 2018-11-22
# Description: Compile kernel with defconfig on ARM64/ARM platform and
#              measure how long it takes.
# ====================

###### specify interpeter path ######

#!/bin/bash 

###### importing environment variable ######

cd ../../../../utils
 source ./sys_info.sh
 source ./sh-test-lib
cd -

###### setting variables ######

OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
LOGFILE="${OUTPUT}/compilation.txt"
VERSION='4.4.34'
NPROC=$(nproc)

usage() {
    echo "Usage: $0 [-v version] [-s true|false]" 1>&2
    exit 1
}

while getopts "v:s:h" o; do
    case "$o" in
        v) VERSION="${OPTARG}" ;;
        s) SKIP_INSTALL="${OPTARG}" ;;
        h|*) usage ;;
    esac
done

###### install list ######

dist_name
# shellcheck disable=SC2154
case "${dist}" in
    debian) pkgs="wget time bc xz-utils build-essential" ;;
    centos) pkgs="wget time bc xz gcc make" ;;
esac

###### check root ######

! check_root && error_msg "You need to be root to install packages!"

###### install package ######

# install_deps supports the above distributions.
# It will skip package installation on other distributions by default.
install_deps "${pkgs}" "${SKIP_INSTALL}"
print_info $? install-pkg
create_out_dir "${OUTPUT}"
cd "${OUTPUT}"

###### download ######

# Download and extract Kernel tarball.
major_version=$(echo "${VERSION}" | awk -F'.' '{print $1}')
wget "https://cdn.kernel.org/pub/linux/kernel/v${major_version}.x/linux-${VERSION}.tar.xz"
tar xf "linux-${VERSION}.tar.xz"
#print_info $? download-kernel-tarball
cd "linux-${VERSION}"

###### testing step ######

# Compile Kernel with defconfig.
# It is native not cross compiling.
# It will not work on x86.
detect_abi
# shellcheck disable=SC2154
case "${abi}" in
    arm64|armeabi)
        make defconfig
        { time -p make -j"${NPROC}" Image; } 2>&1 | tee "${LOGFILE}"
        print_info $? compile-kernel
        ;;
    *)
        error_msg "Unsupported architecture!"
        ;;
esac

measurement="$(grep "^real" "${LOGFILE}" | awk '{print $2}')"
if egrep "arch/.*/boot/Image" "${LOGFILE}"; then
    report_pass "compilation"
    add_metric "compilation-time" "pass" "${measurement}" "seconds"
    print_info $? kernel-pass
else
    report_fail "compilation"
    add_metric "compilation-time" "fail" "${measurement}" "seconds"
    print_info $? kernel-fail
fi

###### restore environment ######

# Cleanup.
cd ../
rm -rf "linux-${VERSION}"*
print_info $? remove-file

