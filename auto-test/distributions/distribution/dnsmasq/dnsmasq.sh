#!/bin/sh
# Author: mahongxin <hongxin_228@163.com>
set -x
cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

#Test user id
if [ `whoami` != 'root' ]; then
    echo " You must be the superuser to run this script" >&2
    exit 1
fi
case $distro in
    "centos")
        #yum install dnsmasq -y
        #yum install bind-utils -y
        pkgs="dnsmasq bind-utils"
        install_deps "${pkgs}"
        print_info $? install-pip
        ;;
    "ubuntu")
        #apt-get install dnsmasq -y
        #apt-get install bind9 -y
        pkgs="dnsmasq bind9"
        install_deps "${pkgs}"
        print_info $? install-dnsmasq
        ;;
esac
DNSMASQ_CONF=/etc/dnsmasq.conf
cp /etc/dnsmasq.conf /etc/dnsmasq.conf_bak
sed -i 's/#resolv-file=/resolv-file=\/etc\/resolv.dnsmasq.conf/g' $DNSMASQ_CONF
sed -i 's/#strict-order/strict-order/g' $DNSMASQ_CONF
sed -i 's/#addn-hosts=\/etc\/banner_add_hosts/addn-hosts=\/etc\/dnsmasq.hosts/g' $DNSMASQ_CONF
sed -i 's/#listen-address=/listen-address=127.0.0.1/g' $DNSMASQ_CONF
echo 'nameserver 127.0.0.1' > /etc/resolv.conf
touch /etc/resolv.dnsmasq.conf
echo 'nameserver 119.29.29.29' > /etc/resolv.dnsmasq.conf
cp /etc/hosts /etc/dnsmasq.hosts
echo 'addn-hosts=/etc/dnsmasq.hosts' >> /etc/dnsmasq.conf
service dnsmasq start
print_info $? start-dnsmasq
dig www.freehao123.com
print_info $? dig-wwwfree

case $distro in
    "centos")
        #yum remove dnsmasq -y
        #yum remove bind-utils -y
        remove_deps "${pkgs}"
        print_info $? remove-pip
        ;;
    "ubuntu")
        #apt-get remove dnsmasq -y
        #apt-get remove bind9 -y
        remove_deps "${pkgs}"
        print_info $? remove-dnsmasq
        ;;
esac
sed -i 's/nameserver 127.0.0.1/nameserver 114.114.114.114/g' /etc/resolv.conf
