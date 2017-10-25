#!/bin/sh
#DNS is the server responsibel for domain name resolution
#Author:mahongxin <hongxin_228@163.com>
set -x
cd utils
. ./sys_info.sh
cd -
#Test user id
if [ `whoami` != 'root' ]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
case $distro in
    "centos")
        yum install bind-chroot bind -y
        ;;
esac
#Copy the bind file to prepare the bind chroot environment
cp -R /usr/share/doc/bind-*/sample/var/named/* /var/named/chroot/var/named/
#create the relevant files in the bind chroot directory
touch /var/named/chroot/var/named/data/cache_dump.db
touch /var/named/chroot/var/named/data/named_stats.txt
touch /var/named/chroot/var/named/data/name_mem_stats.txt
touch /var/named/chroot/var/named/data/named.run
mkdir /var/named/chroot/var/named/dynamic
touch /var/named/chroot/var/named/dynamic/managed-keys.bind
#set the Bind lock file to writable
chmod -R 777 /var/named/chroot/var/named/data
chmod -R 777 /var/named/chroot/var/named/dynamic
#copy /etc/name.conf to the bind chroot directory
cp -p /etc/named.conf /var/named/chroot/etc/named.conf
#configure bind in /etc/names.conf
sed -i 's/127.0.0.1/any/g' /var/named/chroot/etc/named.conf
sed -i 's/localhost/any/g' /var/named/chroot/etc/named.conf
sed '52a zone "example.local" \{ \ntype master; \nfile "example.local.zone";\n\};\
\nzone "1.168.192.in-addr.arpa" IN \{ \ntype master; \nfile "192.168.1.zone;\n\};' /var/named/chroot/etc/named.conf
#create forward domain
cat << EOF >> /var/named/chroot/var/named/example.local.zone
;
;    Addresses and other host information
;
$TTL 86400
@       IN    SOA    example.local. hostmaster.example.local. (
                        2014101901      ; Serial
                        43200           ; Refresh
                        3600            ; Retry
                        3600000         ; Expire
                        2592000)        ; Minimum
;      Define the nameservers and the mail servers
          IN      NS      ns1.example.local.
          IN      NS      ns2.example.local.
          IN      A       192.168.1.70
          IN      MX      10 mx.example.local.
centos7         IN  A     192.168.1.70
mx              IN　A     192.168.1.50
ns1             IN  A     192.168.1.70
ns2             IN  A     192.168.1.80
EOF
cat << EOF >> /var/named/chroot/var/named/192.168.1.zone
;
;    Addresses and other host information
;
$TTL 86400
@       IN    SOA    example.local. hostmaster.example.local. (
                        2014101901      ;  Serial
                        43200           ;  Retry
                        3600            ;  Retry
                        3600000         ;  Expire
                        2592000)        ;  Minimum
1.168.192.in-addr.addr.arpa. IN    NS    centos7.example.local.

70.1.168.192.in-addr.arpa. IN PTR mx.example.local.
70.1.168.192.in-addr.arpa. IN PTR ns1.example.local.
80.1.168.192.in-addr.arpa. IN PTR ns2.example.local.
EOF
#Boot from the bind-chroot
/usr/libexec/setup-named-chroot.sh /var/named/chroot on
systemctl stop named
systemctl disable named
systemctl start named-chroot
systemctl enable named-chroot
ln -s '/usr/lib/systemd/system/named-chroot.service' '/etc/systemd/system/multi-user.target.wants/named-chroot.service'
board_ip=`ifconfig |grep "inet"|cut -c14-26|head -n 1`
dig @${board_ip} example.local 2>&1 |tee dig.log
throu1=`grep -Po "ns1.example.local." dig.log`
TCID1="DNS test pass"
if [ "$throu1" != "" ]; then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi


