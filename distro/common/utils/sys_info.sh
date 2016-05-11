#!/bin/bash

sys_info=$(uname -a)
distro=""
if [ "$(echo $sys_info |grep -E 'UBUNTU|Ubuntu|ubuntu')" ]; then 
    distro="ubuntu"
elif [ $(echo $sys_info |grep -E 'CENTOS|CentOS|centos') ]; then
    distro="centos"
elif [ $(echo $sys_info |grep -E 'FEDORA|Fedora|fedora') ]; then
    distro="fedora"
elif [ $(echo $sys_info |grep -E 'DEBIAN|Debian|debian') ]; then
    dsstro="debian"
elif [ $(echo $sys_info |grep -E 'OPENSUSE|OpenSuse|opensuse') ]; then
    distro="opensuse"
else
    distro="ubuntu"
fi

local_ip=$(ifconfig `route -n | grep "^0"|awk '{print $NF}'`|grep -o "addr inet:[0-9\.]*"|cut -d':' -f 2)
if [ ${local_ip}x != ""x ]; then
    local_ip=$(ip addr show `ip route | grep "default" | awk '{print $NF}'`| grep -o "inet [0-9\.]*" | cut -d" " -f 2)
fi

restart_service="systemctl restart"
start_service="systemctl start"
status_service="systemctl status"

case $distro in 
    "ubuntu" | "debian" )
        update_commands="apt-get update"
        install_commands="apt-get install -y"
        restart_service=""
        start_service=""
        status_service=""
        ;;
    "opensuse" )
        update_commands="zypper -n update"
        install_commands="zypper -n install"
        ;;
    "centos" )
        update_commands="yum update"
        install_commands="yum install -y"
        ;;
    "fedora" )
        update_commands="dnf update"
        install_commands="dnf install -y"
        ;;
esac
 
