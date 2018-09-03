#!/bin/bash
cd ../../../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -

case $distro in
    "centos"|"fedora"|"opensuse")
	pkgs="net-tools ethtool"
	install_deps "$pkgs"
        ;;
        ubuntu|debian)
        #apt-get install ethtool -y
	pkgs="ethtool"
        install_deps "$pkgs" 
esac
	
inet=`ip link|grep "state UP"|awk '{print $2}'|head -1|sed 's/0:/9/g'`
echo $inet

ETI=`ethtool -i $inet`
echo $ETI

if [ '$ETI|grep "No such device"' != "" ]; then
	
	lava-test-case "fault_driver" --result pass
else
	lava-test-case "fault_driver" --result fail
fi

