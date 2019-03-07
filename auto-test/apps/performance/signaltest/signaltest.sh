#!/bin/bash 
# signaltest is a RT signal roundtrip test software.

# shellcheck disable=SC1091
set -x

#####加载外部文件################
cd ../../../../utils
source      ./sys_info.sh
source       ./sh-test-lib
cd -

#############################  Test user id       #########################
! check_root && error_msg "Please run this script as root."

######################## Environmental preparation   ######################
OUTPUT="$(pwd)/output"
LOGFILE="${OUTPUT}/signaltest.txt"
RESULT_FILE="${OUTPUT}/result.txt"

PRIORITY="99"
THREADS="2"
LOOPS="10000"

while getopts ":p:t:l:" opt; do
    case "${opt}" in
        p) PRIORITY="${OPTARG}" ;;
        t) THREADS="${OPTARG}" ;;
        l) LOOPS="${OPTARG}" ;;
        *) usage ;;
    esac
done

#######################  testing the step ###########################
create_out_dir "${OUTPUT}"

# Run signaltest.
detect_abi
# shellcheck disable=SC2154
./bin/"${abi}"/signaltest -p "${PRIORITY}" -t "${THREADS}" -l "${LOOPS}" \
    | tee "${LOGFILE}"

# Parse test log.
tail -n 1 "${LOGFILE}" \
    | awk '{printf("min-latency pass %s us\n", $(NF-6))};
           {printf("avg-latency pass %s us\n", $(NF-2))};
           {printf("max-latency pass %s us\n", $NF)};'  \
    | tee -a "${RESULT_FILE}"

if [-z "$min-latency"];then
   print_info 1 RT-min
else
   print_info 0 RT-min
fi

if [-z "$avg-latency"];then
   print_info 1 RT-avg
else
   print_info 0 RT-avg
fi

if [-z "$max-latency"];then
   print_info 1 RT-latency
else
   print_info 0 RT-latency
fi

