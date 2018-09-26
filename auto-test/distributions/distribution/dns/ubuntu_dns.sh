#!/bin/bash
#Author mahongxin<hongxin_228@163.com>
set -x
cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -
if [ `whoami` != 'root' ]; then
    echo "You must be the superuser to run this script" >$2
    exit 1
fi
case $distro in
    "ubuntu")
        apt-get install dnsutils dig -y;
        apt-get install bind9 -y;
        print_info $? install-dns
        ;;
esac
cat << EOF > /etc/bind/named.conf.local
zone "tonv.my" {
    type master;
    file "/etc/bind/zones/tonv.my.db";
};
zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/rev.1.168.192.in-addr.arpa";
};
EOF
cd /etc/bind
mkdir zones
cat << EOF > /etc/bind/zones/tonv.my.db
tonv.my. IN SOA ns1.tonv.my. admin.tonv.my. (
2007031001
28800
3600
604800
38400
)
tonv.my. IN NS ns1.tonv.my.
www IN A 192.168.1.70
ns1 IN A 192.168.1.80
mail IN A 192.168.1.90
EOF
cat << EOF > /etc/bind/zones/rev.1.168.192.in-addr.arpa
@ IN SOA ns1.tonv.my. admin.tonv.my. (
2007031001;
28800;
604800;
604800;
86400
)
@ IN NS ns1.tonv.my.
70 IN PTR tonv.my.
80 IN PTR ns1.tonv.my.
90 IN PTR mail.tonv.my.
EOF
service bind9 restart
print_info $? start-dns
board_ip=`ifconfig |grep "inet"|cut -c14-26|head -n 1`
echo $borad_ip
#sed -i '1i \nameserver 192.168.1.254' /etc/resolv.conf
sed -i "s/nameserver/#nameserver/g" /etc/resolv.conf
sed -i "1i nameserver ${board_ip}" /etc/resolv.conf
#sed -i "nameserver ${board_ip}" /etc/resolv.conf
service bind9 restart
dig host www.tonv.my
print_info $? forward-dns
dig 192.168.1.70 2>&1 | tee -a dig.log
print_info $? reverse-dns
#throu = `grep -Po "192.168.1.70" nfs.log`
case $distro in
    "ubuntu")
        apt-get remove bind9 -y;
        print_info $? remove-package
        ;;
esac
