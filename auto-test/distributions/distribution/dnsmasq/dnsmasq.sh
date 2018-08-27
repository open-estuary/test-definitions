#!/bin/bash
# Author: mahongxin <hongxin_228@163.com>
set -x
cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

if [ `whoami` != "root" ];then
	echo "YOu must be the root to run this script" >$2
	exit 1
fi


IFCONFIG=`ip link|grep "state UP"|awk '{print $2}'|sed "s/://g"|head -1`

case $distro in
    "centos"|"fedora")
        yum install net-tools
        IP=`ifconfig ${IFCONFIG}|grep "inet "|awk '{print $2}'`
        echo ${IP}
        ;;
    "ubuntu"|"debian")
        apt install net-tools
        IP=`ifconfig ${IFCONFIG}|grep "inet "|awk '{print $2}'`
        echo ${IP}
        ;;
    "opensuse")
        zypper install net-tools
        IP=`ifconfig ${IFCONFIG}|grep "inet "|awk '{print $2}'|awk -F ':' '{print $2}'`
        echo ${IP}
        ;;
esac


#Test user id
if [ `whoami` != 'root' ]; then
    echo " You must be the superuser to run this script" >&2
    exit 1
fi

#Install the package
case $distro in
    "centos"|"fedora")
       pkgs="dnsmasq bind-utils"
        install_deps "${pkgs}"
        print_info $? install-dnsmasq
        ;;
    "ubuntu"|"debian")
        pkgs="dnsmasq dnsutils"
        install_deps "${pkgs}"
        print_info $? install-dnsmasq
        ;;
    "opensuse")
	pkgs="dnsmasq bind-utils"
	install_deps "${pkgs}"
	print_info $? install-dnsmasq
        ;;
esac

#Modify configuration file
DNSMASQ_CONF=/etc/dnsmasq.conf
cp /etc/dnsmasq.conf /etc/dnsmasq.conf_bak
sed -i "s/#resolv-file=/resolv-file=\/etc\/resolv.dnsmasq.conf/g" $DNSMASQ_CONF
sed -i "s/#strict-order/strict-order/g" $DNSMASQ_CONF
sed -i "s/#addn-hosts=\/etc\/banner_add_hosts/addn-hosts=\/etc\/dnsmasq.hosts/g" $DNSMASQ_CONF
sed -i "s/#listen-address=/listen-address=127.0.0.1,${IP}/g" $DNSMASQ_CONF
echo 'nameserver 127.0.0.1' > /etc/resolv.conf
touch /etc/resolv.dnsmasq.conf
echo 'nameserver 8.8.8.8' > /etc/resolv.dnsmasq.conf
cp /etc/hosts /etc/dnsmasq.hosts
echo 'addn-hosts=/etc/dnsmasq.hosts' >> /etc/dnsmasq.conf

#Start the service
case $distro in
    "centos"|"fedora"|"opensuse")
	systemctl start dnsmasq
	print_info $? start-dnsmasq
	;;
    "ubuntu"|"debian")
	service dnsmasq start
	print_info $? start-dnsmasq
	;;
esac
#test
dig www.baidu.com
print_info $? dig_test

#Change hosts to implement DNS hijacking
echo "${IP} www.aaaa.com" >> /etc/dnsmasq.hosts
case $distro in
    "centos")
	systemctl restart dnsmasq
	systemctl start firewalld
	firewall-cmd --add-service=dns --permanent
	firewall-cmd --reload
        ;;
    "ubuntu"|"debian")
	service dnsmasq restart
	;;
    "fedora"|"opensuse")
	systemctl restart dnsmasq
	;;
esac
ping -c 5 www.aaaa.com
print_info $? DNS_hijacking



#The specified domain name is resolved to a specific IP
echo "address=/freehao123.com/${IP}" >> /etc/dnsmasq.conf
case $distro in
    "centos"|"fedora"|"opensuse")
        systemctl restart dnsmasq
        ;;
    "ubuntu"|"debian")
        service dnsmasq restart
        ;;
esac
res=`dig freehao123.com|grep "${IP}"|awk 'NR==1{print}'|awk '{print $5}'`
if [ "${res}"x == "${IP}"x ];then
	print_info 0 specified_ip
else
	print_info 1 specified_ip
fi

#Uninstall software
case $distro in
    "centos"|"fedora")
        remove_deps "${pkgs}"
        print_info $? remove-dnsmasq
        ;;
    "ubuntu"|"debian")
        remove_deps "${pkgs}"
        print_info $? remove-dnsmasq
        ;;
    "opensuse")
       remove_deps "${pkgs}"
        print_info $? remove-dnsmasq
        ;;
esac
sed -i 's/nameserver 127.0.0.1/nameserver 114.114.114.114/g' /etc/resolv.conf
case $distro in
    "debian"|"fedora")
	sed -i "s%addn-hosts=/etc/dnsmasq.hosts%%g" /etc/dnsmasq.conf
	sed -i "s%address=/freehao123.com/${IP}%%g" /etc/dnsmasq.conf
	sed -i "s%resolv-file=/etc/resolv.dnsmasq.conf%#resolv-file=%g" /etc/dnsmasq.conf
	sed -i "s/strict-order/#strict-order/g" /etc/dnsmasq.conf
	sed -i "s%addn-hosts=/etc/dnsmasq.hosts%#addn-hosts=/etc/banner_add_hosts%g" /etc/dnsmasq.conf
	sed -i "s/listen-address=127.0.0.1,${IP}/#listen-address=/g" /etc/dnsmasq.conf
	;;
esac
