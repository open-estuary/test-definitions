#!/bin/sh
# USB smoke test cases
. ../../utils/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
STATUS=0

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

version="007"
from_repo="base"
package="usbutils"
for P in ${package};do
    echo "$P install"

# Check the package version && source
from=$(yum info $P | grep "From repo" | awk '{print $4}')
if [ "$from" = "$from_repo"  ];then
           echo "$P source is $from : [pass]" | tee -a ${RESULT_FILE}
else
     rmflag=1
      if [ "$from" != "base"  ];then
           yum remove -y $P
            yum install -y $P
             from=$(yum info $P | grep "From repo" | awk '{print $4}')
             if [ "$from" = "$from_repo"   ];then
                    echo "$P install  [pass]" | tee -a ${RESULT_FILE}
            else
                   echo "$P source is $from : [failed]" | tee -a ${RESULT_FILE}
               fi
    fi
fi

vers=$(yum info $P | grep "Version" | awk '{print $3}')
if [ "$vers" = "$version"   ];then
    echo "$P version is $vers : [pass]" | tee -a ${RESULT_FILE}
else
  echo "$P version is $vers : [failed]" | tee -a ${RESULT_FILE}
fi
done

increment_return_status() {
    exit_code="$?"
    [ "$#" -ne 1 ] && error_msg "Usage: increment_return_status value"
    value="$1"
    return "$((exit_code+value))"
}

# Get the usb devices/hubs list
list_all_usb_devices() {
    info_msg "Running list-all-usb-devices test..."
    lsusb
    exit_on_fail "lsusb"
}

# Examine all usb devices/hubs
examine_all_usb_devices() {
    info_msg "Running examine_all_usb_devices test..."
    USB_BUS="/dev/bus/usb/"
    if [ -d "${USB_BUS}" ]; then
	# shellcheck disable=SC2045
        for bus in $(ls "${USB_BUS}"); do
	    # shellcheck disable=SC2045
            for device in $(ls "${USB_BUS}""${bus}"/); do
                info_msg "USB Bus ${bus}, device ${device}"
                lsusb -D "${USB_BUS}""${bus}"/"${device}"
                increment_return_status "${STATUS}"
                STATUS=$?
            done
        done
        if [ "${STATUS}" -ne 0 ]; then
            report_fail "examine-all-usb-devices"
        else
            report_pass "examine-all-usb-devices"
        fi
    else
        report_fail "examine-all-usb-devices"
    fi
}

# Print supported usb protocols
print_supported_usb_protocols() {
    info_msg "Running print-supported-usb-protocols test..."
    lsusb -v | grep -i bcdusb
    check_return "print-supported-usb-protocols"
}

# Print supported usb speeds
print_supported_usb_speeds() {
    info_msg "Running print-supported-usb-speeds test..."
    lsusb -t
    check_return "print-supported-usb-speeds"
}

# Test run.
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"

info_msg "About to run USB test..."
info_msg "Output directory: ${OUTPUT}"

# Install usbutils package
pkgs="usbutils"
install_deps "${pkgs}" "${SKIP_INSTALL}"

list_all_usb_devices
examine_all_usb_devices
print_supported_usb_protocols
print_supported_usb_speeds

# Remove usbutils package
pkgs="usbutils"
yum remove -y "${pkgs}"
print_info $? remove
