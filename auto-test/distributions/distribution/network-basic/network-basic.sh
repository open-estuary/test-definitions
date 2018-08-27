#!/bin/bash
. ../../../../utils/sys_info.sh
. ../../../../utils/sh-test-lib
cd -

if [ `whoami` != "root" ];then
	echo "YOu must be the root to run this script" >$2
	exit 1
fi

INTERFACE=`ip link|grep "state UP"|awk '{print $2}'|sed "s/://g"|head -1`


case $distro in
    "centos"|"ubuntu"|"debian"|"fedora")
	      pkgs="curl net-tools"
	      install_deps "${pkgs}"
	      print_info $? install-pkgs
        ;;
    "opensuse")
	      pkgs="curl net-tools dhcp-client"
	      install_deps "${pkgs}"
        print_info $? install-pkgs
        ;;
esac

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


case $distro in
    "ubuntu"|"debian"|"centos"|"fedora")
	        run "netstat -an" "print-network-statistics"
	        print_info $? netstat

        	run "route" "print-routing-tables"
	        print_info $? route

	        run "ip link set lo up" "ip-link-loopback-up"
	        print_info $? ip-link
	
	        run "route" "route-dump-after-ip-link-loopback-up"
	        print_info $? route-dump
        	;;
    "opensuse")
	        run "ss -an" "print-network-statistics"
          print_info $? netstat

	        run "ip route" "print-routing-info"
          print_info $? route_info

        	run "ip link set lo up" "ip-link-loopback-up"
          print_info $? ip-link

          run "ip route" "route-dump-after-ip-link-loopback-up"
          print_info $? route-dump
          ;;
esac

run "ip addr" "list-all-network-interfaces"
print_info $? ip-addr

run "ping -c 5 ${GATEWAY}" "ping-gateway"
print_info $? ping-gateway

run "curl http://192.168.50.122:8083/test_dependents/lmbench3.tar.gz -o lmbench3" "download-a-file"
print_info $? curl

rm -rf lmbench3.tar.gz 

case $distro in
    "opensuse")
      	zypper remove -y net-tools
	      zypper remove -y dhcp-client 
      	print_info $? removse-pkgs
	      ;;
    "ubuntu"|"debian"|"centos"|"fedora")
	      remove_deps "net-tools"
	      print_info $? removse-pkgs
      	;;
esac




