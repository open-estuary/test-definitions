#!/bin/sh

# shellcheck disable=SC1091
#Author: mahongxin <hongxin_228@163.com>
set -x
cd ../../utils
  . ./sys_info.sh
cd -
#Test user_id
if [ `whoami` != 'root' ]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
#distro=` cat /etc/redhat-release | cut -b 1-6`
case $distro in
    "centos")
        yum install net-tools.aarch64 -y
        ;;
esac

# Default ethernet interface
INTERFACE="eth0"
# Print all network interface status
ip addr
# Print given network interface status
ip addr show "${INTERFACE}"

# Get IP address of a given interface
IP_ADDR=$(ip addr show "${INTERFACE}" | grep -a2 "state UP" | tail -1 | awk '{print $2}' | cut -f1 -d'/')
TCID="test-IP"
if [ -n "${IP_ADDR}" ];then
    lava-test-case $TCID --result fail
else
    lava-test-case $TCID --result pass
fi
# Get default Route IP address of a given interface
ROUTE_ADDR=$(ip route list  | grep default | awk '{print $3}' | head -1)

# Run the test
ping -c 5 ${ROUTE_ADDR} 2>&1 | tee ether.log
str="0 packet loss"
TCID1="ethernet-ping-route"
if [ "$str" != "" ] ; then
    lava-test-case $TCID1 --result fail
else
    lava-test-case $TCID1 --result pass
fi
