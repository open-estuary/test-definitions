#!/bin/sh
# USB smoke test cases
cd ../../../../utils
    .        ./sys_info.sh
    .        ./sh-test-lib
cd -
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
    print_info $? lsusb
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
                print_info $? exam_$bus_$device 
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
    print_info $? protocols 
    check_return "print-supported-usb-protocols"
}

# Print supported usb speeds
print_supported_usb_speeds() {
    info_msg "Running print-supported-usb-speeds test..."
    lsusb -t
    print_info $? lsusb support_speed 
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
print_info $? install

list_all_usb_devices
examine_all_usb_devices
print_supported_usb_protocols
print_supported_usb_speeds

# Remove usbutils package
pkgs="usbutils"
yum remove -y "${pkgs}"
print_info $? remove
