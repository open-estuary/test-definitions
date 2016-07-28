#!/bin/bash

function config_brctl()
{
    ip_segment=$(ip addr show `ip route | grep "default" | awk '{print $NF}'`| grep -o "inet [0-9\.]*" | cut -d" " -f 2 | cut -d"." -f 3)

    if [ x"$(cat  /etc/sysconfig/network-scripts/ifcfg-lo | grep TYPE)" = x"" ];
    then
        echo "TYPE=lookback" >> /etc/sysconfig/network-scripts/ifcfg-lo
    fi

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-virbr0
DEVICE="virbr0"
BOOTPROTO="static"
IPADDR="192.168.${ip_segment}.123"
NETMASK="255.255.255.0"
ONBOOT="yes"
TYPE="Bridge"
NM_CONTROLLED="no"
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
EOF
    $stop_service firewalld.service
    $disable_service firewalld.service
    $enable_service NetworkManager-wait-online.service
}

pushd ./utils
. ./sys_info.sh
popd

config_output=$(lxc-checkconfig)
[[ $config_output =~ 'missing' ]] && print_info 1 lxc-checkconfig
[[ $config_output =~ 'missing' ]] || print_info 0 lxc-checkconfig

set -x

case $distro in 
    "ubuntu" )
        echo "lxc.aa_allow_incomplete = 1"  >> /var/lib/lxc/${distro}/config
        ;;
    "fedora" )
        sed -i 's/type ubuntu-cloudimg-query/#type ubuntu-cloudimg-query/g' /usr/share/lxc/templates/lxc-ubuntu-cloud
        sed -i 's/xpJf/xpf/g' /usr/share/lxc/templates/lxc-ubuntu-cloud
        #cp /etc/lxc/default.conf /etc/lxc/default.conf_bk
        sed -i "s/lxcbr0/virbr0/g"  /etc/lxc/default.conf
        brtcl_exist=$(ip addr | grep virbr0)
        if [ x"$brtcl_exist" = ""x ]; then
            config_brctl
        fi
        $restart_service libvirtd.service
        $restart_service network.service
        ;;
    "centos" )
        sed -i 's/type ubuntu-cloudimg-query/#type ubuntu-cloudimg-query/g' /usr/local/share/lxc/templates/lxc-ubuntu-cloud
        ;;
esac

distro_name=ubuntu
lxc-create -n $distro_name -t ubuntu-cloud -- -r vivid -T http://htsat.vicp.cc:808/docker-image/ubuntu-15.04-server-cloudimg-arm64-root.tar.gz
print_info $? lxc-create

distro_exists=$(lxc-ls --fancy)
[[ "${distro_exists}" =~ $distro_name ]] && print_info 0 lxc-ls
[[ "${distro_exists}" =~ $distro_name ]] || print_info 1 lxc-ls


lxc-start --name $distro_name --daemon
result=$?

lxc_status=$(lxc-info --name $distro_name)
if [ "$(echo $lxc_status | grep $distro_name | grep 'RUNNING')" = ""x -a $result -ne 0 ]; then
    print_info 1 lxc-start
else
    print_info 0 lxc-start
fi

/usr/bin/expect <<EOF
set timeout 400
spawn lxc-attach -n $distro_name
expect "ubuntu"
send "exit\r"
expect eof
EOF
print_info $? lxc-attach

lxc-execute -n $distro_name /bin/echo hello
print_info $? lxc-execute

lxc-stop --name $distro_name
print_info $? lxc-stop

lxc-destroy --name $distro_name
print_info $? lxc-destory

$install_commands lxc-tests
install_results=$?
print_info $install_results install-lxc-tests
if [ $install_results -eq 0 ]; then
   for i in /usr/bin/lxc-test-*
   do 
       $i
       print_info $? "$i"
   done
fi
