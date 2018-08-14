#!/bin/bash
cd ../../../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -

case $distro in
    "centos"|"fedora"|"opensuse")
        #yum install net-tools -y
        pkgs="net-tools"
        install_deps "$pkgs"
        ;;
        ubuntu|debian)
        #apt-get install ethtool -y
        pkgs="ethtool"
        install_deps "$pkgs" 
esac

#网口驱动版本信息driver: hns
#                version: 2.0

#列出网口
inet0=`ip link|grep "BROADCAST"|awk '{print $2}'|sed 's/://g'`
echo $inet0

#查询网口版本信息
for i in $inet0
do
	ethtool -i $i |egrep "driver: hns|version: 2.0" 
if	[ $? = 0 ];then
	echo $i >> 1.log
fi
done

TCID="driver-version"
if [ `cat 1.log|wc -l` == 4 ]; then
    lava-test-case $TCID --result pass
else  
    lava-test-case $TCID --result fail
fi
rm -f 1.log

#网口up
inet1=`ip link|grep "BROADCAST"|awk '{print $2}'|sed 's/://g'`
echo $inet1

for a in $inet1
do
ifconfig $a up
done

for a in $inet1
do
        ethtool -i $a |egrep "driver: hns|version: 2.0"
if      [ $? = 0 ];then
        echo $a >> 1.log
fi
done


TCID="up-driver-version"
if [ `cat 1.log|wc -l` == 4 ]; then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi
rm -f 1.log

#网口down
inet2=`ip link|grep "BROADCAST"|awk '{print $2}'|sed 's/://g'`
echo $inet2

for b in $inet2
do
ifconfig $b down
done
for b in $inet2
do
        ethtool -i $b |egrep "driver: hns|version: 2.0"
if      [ $? = 0 ];then
        echo $b >> 1.log
fi
done

TCID="down-driver-version"
if [ `cat 1.log|wc -l` == 4 ]; then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi
rm -f 1.log

