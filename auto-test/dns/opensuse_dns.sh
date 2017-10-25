#!/bin/sh
#Author mahongxin<hongxin_228@163.com>
set -x
cd utils
. ./sys_info.sh
cd -
if [ `whoami` != 'root' ]; then
    echo "You must be the superuser to run this script" >$2
    exit 1
fi
case $distro in
    "opensuse")
        zypper install -y bind ;
        zypper install -y expect;
        ;;
esac
mv  /etc/named.conf /etc/named.conf_bak
cat << EOF >> /etc/named.conf
zone "tonv.my" in {
    type master;
    file "/var/lib/named/master/tonv.my.db";
};
zone "1.168.192.in-addr.arpa" in {
    type master;
    file "/var/lib/named/master/rev.1.168.192.in-addr.arpa";
};
EOF
cd /var/lib/named/master
#mkdir zones
cat << EOF >> /var/lib/named/master/tonv.my.db
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
cat << EOF >> /var/lib/named/master/rev.1.168.192.in-addr.arpa
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
systemctl restart named.service
board_ip=`ifconfig |grep "inet"|cut -c21-34|head -n 1`
sed -i "1i nameserver ${board_ip}" /etc/resolv.conf
systemctl restart named.service
throu=`host www.tonv.my|grep -Po "has address"`

#throu = `grep -Po "192.168.1.70" nfs.log`
TCID="opensuse_dns test"
if [ "$throu" != "" ]; then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi

