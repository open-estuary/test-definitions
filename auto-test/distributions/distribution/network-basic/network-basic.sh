#!/bin/bash
. ../../../../utils/sys_info.sh
. ../../../../utils/sh-test-lib
cd -

INTERFACE=`ip link|grep "state UP"|awk '{print $2}'|sed "s/://g"|head -1`

pkgs="curl net-tools"
install_deps "${pkgs}"
print_info $? install-pkgs


run() {
    test_case="$1"
    test_case_id="$2"
    echo
    info_msg "Running ${test_case_id} test..."
    info_msg "Running ${test_case} test..."
    eval "${test_case}"
    check_return "${test_case_id}"
}


# Test run
# Get default Route Gateway IP address of a given interface
GATEWAY=`ip route list  | grep default | awk '{print $3}'|head -1`

run "netstat -an" "print-network-statistics"
print_info $? netstat

run "ip addr" "list-all-network-interfaces"
print_info $? ip-addr

run "route" "print-routing-tables"
print_info $? route

run "ip link set lo up" "ip-link-loopback-up"
print_info $? ip-link

run "route" "route-dump-after-ip-link-loopback-up"
print_info $? route-dump

run "ip link set dev ${INTERFACE} down" "ip-link-interface-down"
print_info $? ip_link_down

run "ip link set dev ${INTERFACE} up" "ip-link-interface-up"
print_info $? ip_link_up

run "dhclient -v ${INTERFACE}" "Dynamic-Host-Configuration-Protocol-Client-dhclient-v"
print_info $? dhclient

run "route" "print-routing-tables-after-dhclient-request"
run "ping -c 5 ${GATEWAY}" "ping-gateway"
print_info $? ping-gateway

run "curl http://samplemedia.linaro.org/MPEG4/big_buck_bunny_720p_MPEG4_MP3_25fps_3300K.AVI -o curl_video.avi" "download-a-file"
print_info $? curl

remove_deps "net-tools"
print_info $? removse-pkgs




