
##### specify interpeter path #####

#!/bin/bash

##### importing environment variable #####

cd ../../../../utils
    .        ./sys_info.sh
    .        ./sh-test-lib
cd -

OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE

##### setting variables #####

# The number of hardware class may vary dpending on the system under testing.
# This test check if lshw able to report the classes defined in ${CLASSES},
# which are very common ones by default and can be changed with -c.
CLASSES="system bus processor memory network"
 
usage() {
    echo "usage: $0 [-s <true|false>] [-c classes]" 1>&2
    exit 1
}

while getopts ':s:c:' opt; do
    case "${opt}" in
        s) SKIP_INSTALL="${OPTARG}" ;;
        c) CLASSES="${OPTARG}" ;;
        *) usage ;;
    esac
done

##### precheck #####

! check_root && error_msg "lshw must be run as super user or it will only report partial information."
create_out_dir "${OUTPUT}"

##### install #####

install_deps "lshw" "${SKIP_INSTALL}"
print_info $? install-pkg
# If lshw fails to run, skip the following tests and exit.
skip_list=$(echo "${CLASSES}" | awk '{for (i=1; i<=NF; i++) printf("lshw-%s ",$i)}')

##### testing step #####

## lshw ##

lshw > "${OUTPUT}/lshw.txt"
exit_on_fail "lshw-run" "${skip_list}"

## lshw -json ##

# Obtain classes detected by lshw.
lshw -json > "${OUTPUT}/lshw.json"
detected_classes=$(grep '"class" : ' "${OUTPUT}/lshw.json" | awk -F'"' '{print $(NF-1)}' | uniq)

## lshw -class { bus system processor memory network } ##

# Check if lshw able to detect and report the classes defined in ${CLASSES}.
for class in ${CLASSES}; do
    logfile="${OUTPUT}/lshw-${class}.txt"
    if ! echo "${detected_classes}" | grep -q "${class}"; then
        warn_msg "lshw failed to detect ${class} class!"
        report_fail "lshw-${class}"
        print_info $? lshw-${class}
    else
        # lshw may exit with zero and report nothing, so check the size of
        # logfile as well.
        if lshw -class "${class}" > "${logfile}" || ! test -s "${logfile}"; then
            report_pass "lshw-${class}"
            print_info $? lshw-${class}
        else
            report_fail "lshw-${class}"
            
        fi
        cat "${logfile}"
    fi
done

##### restore environment #####

## remove lshw ##

remove_deps lshw
