#!/bin/sh
#DNS is the server responsibel for domain name resolution
#Author:mahongxin <hongxin_228@163.com>
set -x
cd ../../utils
. ./sys_info.sh
cd -
#Test user id
if [ `whoami` != 'root' ]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

case $distro in
    "centos")
        yum install bind -y
        yum install bind-utils -y
        ;;
esac
chmod 777 /etc/named.conf
sed -i 's/127.0.0.1/any/g' /etc/named.conf
sed -i 's/localhost/any/g' /etc/named.conf
sed -i '42a zone "example.com" IN\{ \ntype master; \nfile "example.com.zone";\n\};\
zone "realhostip.com" IN \{ \ntype master; \nfile "named.realhostip.com";\n\};' /etc/named.rfc1912.zones
cp -p /var/named/named.localhost /var/named/example.com.zone

cat << EOF > /var/named/example.com.zone
\$TTL  1D
@       IN    SOA    server1.example.com. root.invalid. (
                        20160614      ; serial
                        1D           ; refresh
                        1H           ; retry
                        1W           ; expire
                        3H )         ; minimum
          NS    server1.example.com.
server1   A     127.0.0.1
www       AAAA  ::1
bbs       CNAME news.example.com.
news      A     192.168.1.70
example.com.    MX 1       192.168.1.70.
EOF
chmod 777 /var/named/example.com.zone

cat << EOF >> /var/named/named.realhostip.com
\$TTL 1D
@       IN    SOA    realhostip.com. rname.invalid. (
                        0               ;  serial
                        1D              ;  refresh
                        1H              ;  retry
                        1W              ;  expire
                        3H )            ;  minimum
       NS     @
       A      127.0.0.1
       AAAA   ::1
192-168-1-70  IN A       192.168.1.70
192-168-1-80  IN A       192.168.1.80
EOF
chmod 777 /var/named/named.realhostip.com
board_ip=`ip addr |grep "inet 192"|cut -c10-22`
sed -i "2i\\nameserver ${board_ip}" /etc/resolv.conf
systemctl restart named.service

dig 192-168-1-70.realhostip.com 2>&1 | tee dig.log

dig -t mx example.com 2>&1 |tee dig1.log
throu1=`grep -Po "192.168.1.70" dig.log`
throu2=`grep -Po "server1.example.com." dig1.log`
TCID1="DNS forward direction "
TCID2="DNS reverse "
if [ "$throu1" != "" ]; then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi
if [ "$throu2" != "" ]; then
    lava-test-case $TCID2 --result pass
else
    lava-test-case $TCID2 --result fail
fi

