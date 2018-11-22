# ==================
# Filename: pm-qa
# Author:
# Email:
# Date:
# Description: Test power management (PM-QA). Currently, the test runs
#              cpufreq, cpuidle, cpuhotplug, thermal and cputopology by
#              default and individual test can be run by setting TESTS
#              parameter in test job definition too
# ==================

###### specify interpeter path ######

#!/bin/bash 

###### importing environment variable ######  

cd ../../../../utils
   source  ./sys_info.sh
   source  ./sh-test-lib
cd -

###### setting variables ######

OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
SKIP_INSTALL="false"

RELEASE="pm-qa-v0.5.2"
TESTS="cpufreq cpuidle cpuhotplug thermal cputopology"

usage() {
    echo "usage: $0 [-r <release>] [-t <tests>] [-s <true|false>] 1>&2"
    exit 1
}

while getopts ":r:t:s:" opt; do
    case "${opt}" in
        r) RELEASE="${OPTARG}" ;;
        t) TESTS="${OPTARG}" ;;
        s) SKIP_INSTALL="${OPTARG}" ;;
        *) usage ;;
    esac
done

###### precheck root ######

! check_root && error_msg "Please run this script as root."

###### install ######

install_deps "git build-essential linux-libc-dev" "${SKIP_INSTALL}"
print_info $? install-pkg
create_out_dir "${OUTPUT}"

###### testing step ######

rm -rf pm-qa
git clone https://git.linaro.org/power/pm-qa.git
print_info $? git-pm-qa
cd pm-qa
git checkout -b "${RELEASE}" "${RELEASE}"
make -C utils

for test in ${TESTS}; do
    logfile="${OUTPUT}/${test}.log"
    make -C "${test}" check 2>&1 | tee  "${logfile}"
    print_info $? ${test}
    grep -E "^[a-z0-9_]+: (pass|fail|skip)" "${logfile}" \
        | sed 's/://g' \
        | tee -a "${RESULT_FILE}"
done
