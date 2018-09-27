#!/bin/bash 
set -x
cd ../../../../utils
source       ./sys_info.sh
source       ./sh-test-lib

cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

case $distro in
       "centos"|"debian"|"fedora"|"ubuntu")
        pkgs="lldpad"
        install_deps "${pkgs}"
        print_info $? lldpad_install
        ;;
       "opensuse")
        pkgs="lldpd"
        install_deps "${pkgs}"
        print_info $? lldpad_install
        ;;
        *)
        exit 1
        ;;
esac


# run the lldp daemon
lldpad -d
print_info $? lldp

# run the script
for i in `ls /sys/class/net/ | grep 'eth\|ens\|eno'` ;
    do echo "enabling lldp for interface: $i" ;
    lldptool set-lldp -i $i adminStatus=rxtx  ;
    lldptool -T -i $i -V  sysName enableTx=yes;
    lldptool -T -i $i -V  portDesc enableTx=yes ;
    lldptool -T -i $i -V  sysDesc enableTx=yes;
    lldptool -T -i $i -V sysCap enableTx=yes;
    lldptool -T -i $i -V mngAddr enableTx=yes;
done
print_info $? script

# check ethernet connection information
inet=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'|awk '{print $1}'| head -1`
lldptool -t -i $inet
print_info $? lldptool

#stop process of lldpad -d
lpid=$(ps -ef|grep lldpad |grep -v "grep"|awk '{print $2}')
kill -9 $lpid
print_info $? kill_lldpad

# Remove package
remove_deps "${pkgs}"
print_info $? remove

