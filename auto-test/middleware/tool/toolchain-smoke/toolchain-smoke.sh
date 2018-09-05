#!/bin/sh 

# shellcheck disable=SC1091
cd ../../../../utils
.            ./sh-test-lib
.            ./sys_info.sh
cd -

OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
STATIC=false

usage() {
    echo "Usage: $0 [-s <true|flase>] [-t <true|flase>]" 1>&2
    exit 1
}

while getopts "s:t:h" o; do
    case "$o" in
        t) STATIC=${OPTARG} ;;
        s) SKIP_INSTALL="${OPTARG}" ;;
        h|*) usage ;;
    esac
done

install() {
    dist_name
    # shellcheck disable=SC2154
    case "${dist}" in
      debian|ubuntu) install_deps "build-essential" "${SKIP_INSTALL}"
        if test $? -eq 0;then
        print_info 0 install 
        else
        print_info 1 install
	exit 1
        fi ;;
      fedora|centos|opensuse) install_deps "gcc glibc-static" "${SKIP_INSTALL}"
        if test $? -eq 0;then
        print_info 0 install
        else
        print_info 1 install
	exit 1
        fi ;;
      unknown) warn_msg "Unsupported distro: package install skipped" ;;
    esac
}

! check_root && error_msg "You need to be root to run this script."
create_out_dir "${OUTPUT}"
cd "${OUTPUT}"

install

FLAGS=""
if [ "${STATIC}" = "true" ] || [ "${STATIC}" = "True" ]; then
    FLAGS="-static"
fi

skip_list="execute_binary"
command="gcc ${FLAGS} -o hello ../hello.c"
run_test_case "${command}" "gcc${FLAGS}" "${skip_list}"
  if test $? -eq 0;then
     print_info 0 gcc 
  else
     print_info 1 gcc
  fi

command="./hello | grep -x 'Hello world'"
# skip_list is used as test case name to avoid typing mistakes
run_test_case "${command}" "${skip_list}"
  if test $? -eq 0;then
     print_info 0  avoid_typing_mistakes
  else
     print_info 1  avoid_typing_mistakes
  fi
 case "${dist}" in
   debian|ubuntu) remove_deps "build-essential" 
      if test $? -eq 0;then
      print_info 0 build-essential_remove 
      else
      print_info 1 build-essential_install
      fi ;;
   fedora|centos) remove_deps "glibc-static" 
      if test $? -eq 0;then
      print_info 0 glibc-static_remove
      else
      print_info 1 glibc-static_remove
      fi ;;
 esac
