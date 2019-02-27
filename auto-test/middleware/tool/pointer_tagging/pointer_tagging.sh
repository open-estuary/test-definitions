#!/bin/sh 
set -x

# shellcheck disable=SC1091
cd  ../../../../utils
.            ./sys_info.sh
.            ./sh-test-lib
cd -

OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE

usage() {
    echo "Usage: $0 [-s <true>]" 1>&2
    exit 1
}

while getopts "s:" o; do
  case "$o" in
    s) SKIP_INSTALL="${OPTARG}" ;;
    *) usage ;;
  esac
done

pointer_tagging_build_test() {

    wget ${ci_http_addr}/test_dependents/pointer-tagging-tests.zip
    unzip pointer-tagging-tests.zip && rm -rf pointer-tagging-tests.zip
    sleep 20
    cd pointer-tagging-tests
    make all
    # Run tests
    for tests in $(./pointer_tagging_tests -l) ; do
	./pointer_tagging_tests -t "${tests}"
        print_info $? "${tests}"
#	check_return "${tests}"
    done
}

# Test run.
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"

info_msg "About to run pointer-tagging-tests  test..."
info_msg "Output directory: ${OUTPUT}"

# Install packages
pkgs="binutils gcc make glibc-static wget unzip"
install_deps "${pkgs}" "${SKIP_INSTALL}"

# Build pointer tagging tests and run tests
pointer_tagging_build_test

#remove_deps "${pkgs}

cd ../
rm -rf pointer-tagging-tests 
if [ $? ];then
      print_info 0 remove
else
      print_info 1 remove
fi 

