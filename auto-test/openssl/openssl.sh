#!/bin/sh
# shellcheck disable=SC1004
# shellcheck disable=SC1091

#. ../../lib/sh-test-lib
#OUTPUT="$(pwd)/output"
#RESULT_FILE="${OUTPUT}/result.txt"
set -x
cd utils
    . ./sys_info.sh
cd -

while getopts "s:" o; do
  case "$o" in
    s) SKIP_INSTALL="${OPTARG}" ;;
    *) usage ;;
  esac
done

#! check_root && error_msg "You need to be root to run this script."
#create_out_dir "${OUTPUT}"
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
case $distro in
    "ubuntu")
         apt-get install openssl -y
         ;;
     "centos")
         yum install openssl -y
         ;;
     "opensuse")
         zypper install -y openssl
         ;;
esac

# Record openssl vesion as it has a big impact on test reuslt.
openssl_version="$(openssl version | awk '{print $2}')"
#add_metric "openssl-version" "pass" "${openssl_version}" "version"

# Test run
TCID="openssl test"
cipher_commands="md5 sha1 sha256 sha512 des des-ede3 aes-128-cbc aes-192-cbc \
                aes-256-cbc rsa2048 dsa2048"
for test in ${cipher_commands}; do
    echo
   # info_msg "Running openssl speed ${test} test"
    openssl speed "${test}" 2>&1 | tee openssl.log

    case "${test}" in
      # Parse asymmetric encryption output.
      rsa2048|dsa2048)
        awk -v test_case_id="${test}" 'match($1$2, test_case_id) \
            {printf("%s-sign pass %s sign/s\n", test_case_id, $(NF-1)); \
            printf("%s-verify pass %s verify/s\n", test_case_id, $NF)}' \
            ${openssl.log} | tee -a openssl.log
        lava-test-case $TCID --result pass
        ;;
      # Parse symmetric encryption output.
      des|des-ede3|aes-128-cbc|aes-192-cbc|aes-256-cbc)
        awk -v test_case_id="${test}" \
            '/^Doing/ {printf("%s-%s pass %d bytes/s\n", test_case_id, $7, $7*$10/3)}' \
            ${openssl.log} | tee -a openssl.log
        lava-test-case $TCID --result pass
        ;;
      *)
        awk -v test_case_id="${test}" \
            '/^Doing/ {printf("%s-%s pass %d bytes/s\n", test_case_id, $6, $6*$9/3)}' \
           ${openssl.log} | tee -a openssl.log
        lava-test-case $TCID --result pass
        ;;
    esac
       # lava-test-case $TCID --result fail
done
