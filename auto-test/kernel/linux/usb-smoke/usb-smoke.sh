#!/bin/bash
# USB smoke test cases
cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib
cd -
set -x
pkg="usbutils"
install_deps "$pkg"
print_info $? install-pkg

# Get the usb devices/hubs list
list_all_usb_devices() {
    lsusb
    print_info $? lsusb
}

# Examine all usb devices/hubs
examine_all_usb_devices() {
    USB_BUS="/dev/bus/usb/"
    if [ -d "${USB_BUS}" ]; then
        for bus in $(ls ${USB_BUS}); do
	    for device in $(ls "${USB_BUS}""$bus"/); do
                lsusb -D "${USB_BUS}""${bus}"/"${device}"
		print_info $? exam-"$device"
            done
        done
        print_info 1 "examine-all-usb-devices"
    else
        print_info 1 "examine-all-usb-devices"
    fi
}

# Print supported usb protocols
print_supported_usb_protocols() {
    lsusb -v | grep -i bcdusb
    print_info $? protocols 
}

# Print supported usb speeds
print_supported_usb_speeds() {
    lsusb -t
    print_info $? lsusb_support_speed 
}


list_all_usb_devices
examine_all_usb_devices
print_supported_usb_protocols
print_supported_usb_speeds

# Remove usbutils package
pkg="usbutils"
remove_deps -y "${pkg}"
print_info $? remove-pkg
