#!/bin/sh
set -x
cd ../../utils
   . ./sys_info.sh
   . ./sh-test-lib
cd -

#. ../../lib/sh-test-lib
#OUTPUT="$(pwd)/output"
#RESULT_FILE="${OUTPUT}/result.txt"
LOGFILE="./ablog.txt"

#usage() {
 #   echo "Usage: $0 [-s <true|false>] [-n <numer_or_requests>] [-c <number_of_requests_at_a_time>] " 1>&2
#    exit 1
#}

NUMBER=1000
CONCURENT=100

#while getopts "s:n:c:" o; do
 # case "$o" in
  #  n) NUMBER="${OPTARG}" ;;
   # c) CONCURENT="${OPTARG}" ;;
    #s) SKIP_INSTALL="${OPTARG}" ;;
    #*) usage ;;
  #esac
#done

#! check_root && error_msg "This script must be run as root"
#create_out_dir "${OUTPUT}"

#dist_name
# Install and configure LEMP.
# systemctl available on Debian 8, CentOS 7 and newer releases.
# shellcheck disable=SC2154
case "${distro}" in
    debian)
        # Stop apache server in case it is installed and running.
        systemctl stop apache2 > /dev/null 2>&1 || true

        pkgs="nginx apache2-utils"
        install_deps "${pkgs}" "${SKIP_INSTALL}"

        systemctl restart nginx
        ;;
    centos)
        # x86_64 nginx package can be installed from epel repo. However, epel
        # project doesn't support ARM arch yet. RPB repo should provide nginx.
        [ "$(uname -m)" = "x86_64" ] && install_deps "epel-release" "${SKIP_INSTALL}"
        pkgs="nginx httpd-tools"
        install_deps "${pkgs}" "${SKIP_INSTALL}"

        # Stop apache server in case it is installed and running.
        systemctl stop httpd.service > /dev/null 2>&1 || true

        systemctl restart nginx
        ;;
    *)
        info_msg "Supported distributions: Debian, CentOS"
        error_msg "Unsupported distribution: ${dist}"
        ;;
esac

# Test Apachebench on NGiNX.
# Default index page should be OK to run ab test
ab -n 1000 -c 100 "http://localhost/index.html" | tee "${LOGFILE}"
# shellcheck disable=SC2129
grep "Time taken for tests:" "${LOGFILE}" | awk '{print "Time-taken-for-tests pass " $5 " s"}'""
print_info $? apachebench-test-on-nginx

# shellcheck disable=SC2129
grep "Complete requests:" "${LOGFILE}" | awk '{print "Complete-requests pass " $3 " items"}'""
print_info $? complete-requests-pass
# shellcheck disable=SC2129
grep "Failed requests:" "${LOGFILE}" | awk '{ORS=""} {print "Failed-requests "; if ($3==0) {print "pass "} else {print "fail "}; print $3 " items\n" }'""
print_info $? Failed reques

# shellcheck disable=SC2129

grep "Write errors:" "${LOGFILE}" | awk '{ORS=""} {print "Write-errors "; if ($3==0) {print "pass "} else {print "fail "}; print $3 " items\n" }' ""
print_info $? write errors
# shellcheck disable=SC2129
grep "Total transferred:" "${LOGFILE}" | awk '{print "Total-transferred pass " $3 " bytes"}'""
print_info $? total taansferred
# shellcheck disable=SC2129
grep "HTML transferred:" "${LOGFILE}" | awk '{print "HTML-transferred pass " $3 " bytes"}' ""
print_info $？Html transferred
# shellcheck disable=SC2129
grep "Requests per second:" "${LOGFILE}" | awk '{print "Requests-per-second  pass " $4 " #/s"}'""
print_info $? request per second
# shellcheck disable=SC2129
grep "Time per request:" "${LOGFILE}" | grep -v "across" | awk '{print "Time-per-request-mean pass " $4 " ms"}'""
printf time per request
# shellcheck disable=SC2129
grep "Time per request:" "${LOGFILE}" | grep "across" | awk '{print "Time-per-request-concurent pass " $4 " ms"}'""
print_info $? time per request
# shellcheck disable=SC2129
grep "Transfer rate:" "${LOGFILE}" | awk '{print "Transfer-rate pass " $3 " kb/s"}'""
print_info $? transfer rate
