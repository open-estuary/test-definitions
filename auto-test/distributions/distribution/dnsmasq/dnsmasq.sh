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


if [ "${ci_http_addr}"x = "http://172.19.20.15:8083"x ];then
	    export http_proxy="http://172.19.20.11:3128"
	    export https_proxy="http://172.19.20.11:3128"
fi

IFCONFIG=`ip link|grep "state UP"|awk '{print $2}'|sed "s/://g"|head -1`
IP=`ip a|grep ${IFCONFIG}|grep "inet "|awk '{print $2}'|cut -d '/' -f 1`

#Install the package
case $distro in
    "centos"|"fedora"|"opensuse")
	pkgs="dnsmasq bind-utils net-tools"
	install_deps "${pkgs}"
        print_info $? install-dnsmasq
        ;;
    "ubuntu"|"debian")
        pkgs="dnsmasq dnsutils net-tools"
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
sed -i "s/#bind-interfaces/bind-interfaces/g" $DNSMASQ_CONF
echo 'nameserver 127.0.0.1' > /etc/resolv.conf
echo 'nameserver 8.8.8.8' > /etc/resolv.dnsmasq.conf

if [ "${ci_http_addr}"x = "http://172.19.20.15:8083"x ];then
        echo -e "nameserver 10.98.48.39\nnameserver 10.72.55.82\nnameserver 10.72.255.100\ndomain huawei.com\nnameserver 10.129.54.130\nnameserver 8.8.8.8" >> /etc/resolv.conf
        echo -e "nameserver 10.98.48.39\nnameserver 10.72.55.82\nnameserver 10.72.255.100\ndomain huawei.com\nnameserver 10.129.54.130\nnameserver 8.8.8.8" >> /etc/resolv.dnsmasq.conf
fi


cp /etc/hosts /etc/dnsmasq.hosts
echo 'addn-hosts=/etc/dnsmasq.hosts' >> /etc/dnsmasq.conf

#Start the service
case $distro in
    "centos"|"fedora")
	systemctl start dnsmasq
      	#print_info $? start-dnsmasq
    	  ;;
    "ubuntu"|"debian")
	service dnsmasq start
	#print_info $? start-dnsmasq
	      ;;
esac

#test
dig www.baidu.com
print_info $? dig_test

#stop the service
case $distro in
    "centos"|"fedora"|"opensuse")
        systemctl stop dnsmasq
        print_info $? stop-dnsmasq
        ;;
    "ubuntu"|"debian")
        service dnsmasq stop
        print_info $? stop-dnsmasq
        ;;
esac




#Uninstall software
case $distro in
    "centos"|"fedora"|"opensuse")
        remove_deps dnsmasq
        print_info $? remove-dnsmasq
        ;;
    "ubuntu"|"debian")
        remove_deps dnsmasq
        print_info $? remove-dnsmasq
        ;;
esac

sed -i 's/nameserver 127.0.0.1/nameserver 114.114.114.114/g' /etc/resolv.conf

case $distro in
    "debian"|"ubuntu")
	sed -i "s%addn-hosts=/etc/dnsmasq.hosts%%g" $DNSMASQ_CONF
	sed -i "s/bind-interfaces/#bind-interfaces/g" $DNSMASQ_CONF
      	sed -i "s%resolv-file=/etc/resolv.dnsmasq.conf%#resolv-file=%g" $DNSMASQ_CONF
	sed -i "s/strict-order/#strict-order/g" $DNSMASQ_CONF
	sed -i "s%addn-hosts=/etc/dnsmasq.hosts%#addn-hosts=/etc/banner_add_hosts%g" $DNSMASQ_CONF
	sed -i "s/listen-address=127.0.0.1,${IP}/#listen-address=/g" $DNSMASQ_CONF
	      ;;
esac

