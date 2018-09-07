#!/bin/sh

# shellcheck disable=SC1091
#Author: mahongxin <hongxin_228@163.com>
set -x
cd ../../../../utils
  . ./sys_info.sh
  . ./sh-test-lib
cd -
set -x
#Test user_id
if [ `whoami` != 'root' ]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
pkgs="net-tools"
#case $distro in
  #  "centos")
        install_deps "${pkgs}"
        print_info $? install-pkgs
   #     ;;
    #"ubuntu")
     #   apt-get install net-tools -y
      #  print_info $? install-pkgs
       #;;
#esac

# Default ethernet interface
#INTERFACE="enahisic2i0"
inet=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'|awk '{print 
$1}'|head -1`
# Print all network interface status
ip addr
# Print given network interface status
ip addr show "${inet}"
print_info $? show-interface
# Get IP address of a given interface
IP_ADDR=$(ip addr show "${inet}" | grep -a2 "state UP" | tail -1 | awk '{print $2}' | cut -f1 -d'/')
TCID="test-IP"
if [ -n "${IP_ADDR}" ];then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi
# Get default Route IP address of a given interface
ROUTE_ADDR=$(ip route list  | grep default | awk '{print $3}' | head -1)
print_info $? network-ip
# Run the test
ping -c 5 ${ROUTE_ADDR} 2>&1 | tee ether.log
print_info $? ping-route
#case $distro in
   # "centos")
        #remove_deps "{pkgs}"
        #print_info $? remove-pkg
    #    ;;
    #"ubuntu")
 #       apt-get install net-tools -y
 #       print_info $? remove-pkg
#esac
