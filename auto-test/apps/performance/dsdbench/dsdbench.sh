#!/bin/sh 
set -x
# This test script run docker storage driver benchmarks and tests.
# Test suite source https://github.com/dmcgowan/dsdbench

# shellcheck disable=SC1091
. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh

#变量赋初值
OUTPUT="$(pwd)/output"
TEST_SUITE="BENCHMARKS"
RESULT_FILE="${OUTPUT}/result.txt"
LOG_FILE="${OUTPUT}/dsbench.txt"

#定义函数说明这个脚本的用法
usage() {
    echo "Usage: $0 [-t <benchmarks|tests>] [-s <true|false>]" 1>&2
    exit 1
}

#可选参数
while getopts "t:s:h" o; do
  case "$o" in
    t) TEST_SUITE="${OPTARG}" ;;
    s) SKIP_INSTALL="${OPTARG}" && export SKIP_INSTALL ;;
    h|*) usage ;;
  esac
done

#执行函数得到发行版的名字
dist_name
# shellcheck disable=SC2154
case "${dist}" in
    debian|ubuntu)
        dist_info
        # shellcheck disable=SC2154
        if [ "${Codename}" = "jessie" ]; then
            install_deps "git libdevmapper-dev"
            install_deps "-t jessie-backports golang"
            print_info $? install-pkgs
        else
            install_deps "git golang libdevmapper-dev"
            print_info $? install-pkgs
        fi
        ;;
    fedora|centos)
        install_deps "git golang device-mapper-devel"
        print_info $? install-pkgs
        ;;
    opensuse)
       install_deps "git go device-mapper-devel"
       print_info $? install-pkgs
        ;;
esac
#检查是不是root，不是root用户的话，则输出错误日志
! check_root && error_msg "You need to be root to run this script."
create_out_dir "${OUTPUT}"
mkdir -p "${OUTPUT}/golang"
cd "${OUTPUT}"
export GOPATH="${OUTPUT}/golang"

#clone源码
if [ "${dist}" != "ubuntu" ];then
git clone https://github.com/dmcgowan/dsdbench
print_info $? down-dsdbench
cd dsdbench
fi
#cp目录
cp -r vendor/ "${GOPATH}/src"

#如果是测试benchmark
if [ "${TEST_SUITE}" = "BENCHMARKS" ]; then
    # Run benchmarks.
    
    DOCKER_GRAPHDRIVER=overlay2 go test -run=NONE -v -bench . \
        | tee "${LOG_FILE}"
    print_info $? dock-bench

    # Parse log file.
    egrep "^Benchmark.*op$" "${LOG_FILE}" \
        | awk '{printf("%s pass %s %s\n", $1,$3,$4)}' \
        | tee -a "${RESULT_FILE}"
elif [ "${TEST_SUITE}" = "TESTS" ]; then
    # Run tests.
    DOCKER_GRAPHDRIVER=overlay2 go test -v . \
        | tee "${LOG_FILE}"
    print_info $? docker-test
    # Parse log file.
    for result in PASS FAIL SKIP; do
        grep "\-\-\- ${result}" "${LOG_FILE}" \
            | awk -v result="${result}" '{printf("%s %s\n", $3,result)}' \
            | tee -a "${RESULT_FILE}"
    done
fi
case $distro in
    "centos")
        yum remove golang device-mapper-devel -y
        print_info $? remove-pkg
        ;;
    "ubuntu"|"debian")
	if [ "${Codename}" = "jessie" ]; then
           remove_deps "libdevmapper-dev"
	   remove_deps "-t jessie-backports golang"
	   print_info $? remove-pkgs
        else
	   remove_deps "golang libdevmapper-dev"
	   print_info $? remove-pkgs
       fi
       ;;
    "fedora")
        dnf remove golang device-mapper-devel -y
	print_info $? remove-pkg
       ;;
    "opensuse")
        remove_deps "go device-mapper-devel"
        print_info $? remove-pkgs
       ;;

esac
