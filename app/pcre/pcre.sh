#!/bin/bash
. ../../lib/sh-test-lib
RESULT_FILE="${OUTPUT}/result.txt"
SKIP_INSTALL="no"
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}
info_msg "Run install_pcre"
install_deps "pcre" "${SKIP_INSTALL}"
info_msg "Run test_pcre"
g++ -o pcre test_pcre -lpcre | tee ${RESULT_FILE}
./pcre | grep "OK, has matched" | tee ${RESULT_FILE}
