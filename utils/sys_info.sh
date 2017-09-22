#!/bin/bash

USERNAME="testing"
PASSWD="open1234asd"

distro=""
sys_info=$(uname -a)

if [ "$(echo $sys_info |grep -E 'UBUNTU|Ubuntu|ubuntu')"x != ""x ]; then
    distro="ubuntu"
elif [ "$(echo $sys_info |grep -E 'cent|CentOS|centos')"x != ""x ]; then
    distro="centos"
elif [ "$(echo $sys_info |grep -E 'fed|Fedora|fedora')"x != ""x ]; then
    distro="fedora"
elif [ "$(echo $sys_info |grep -E 'DEB|Deb|deb')"x != ""x ]; then
    dsstro="debian"
elif [ "$(echo $sys_info |grep -E 'OPENSUSE|OpenSuse|opensuse')"x != ""x ]; then
    distro="opensuse"
else
    distro="ubuntu"
fi

local_ip=$(ip addr show `ip route | grep "default" | awk '{print $NF}'`| grep -o "inet [0-9\.]*" | cut -d" " -f 2)
if [ ${local_ip}x = ""x ]; then
    local_ip=$(ifconfig `route -n | grep "^0"|awk '{print $NF}'`|grep -o "addr inet:[0-9\.]*"|cut -d':' -f 2)
fi

start_service='systemctl start'
stop_service='systemctl stop'
reload_service='systemctl reload'
restart_service='systemctl restart'
enable_service='systemctl enable'
disable_service='systemctl disable'
status_service='systemctl status'

case $distro in
    "ubuntu" | "debian" )
        update_commands='apt-get update -y'
        install_commands='apt-get install -y'
        start_service=""
        reload_service=""
        restart_service=""
        status_service=""
        ;;
    "opensuse" )
        update_commands='zypper -n update'
        install_commands='zypper -n install'
        ;;
    "centos" )
        update_commands='yum update -y'
        install_commands='yum install -y'
        ;;
    "fedora" )
        update_commands='dnf update -y'
        install_commands='dnf install -y'
        ;;
esac

print_info()
{
    if [ $1 -ne 0 ]; then
        result='fail'
    else
        result='pass'
    fi

    test_name=$2
    echo "the result of $test_name is $result"
    lava-test-case $test_name --result $result
}

download_file()
{
    url_address=$1
    let i=0
    while (( $i < 5 )); do
        wget $url_address
        if [ $? -eq 0 ]; then
            break;
        fi
        let "i++"
    done
}
