#!/bin/bash

function config_brctl()
{
    ip_segment=$(ip addr show `ip route | grep "default" | awk '{print $NF}'`| grep -o "inet [0-9\.]*" | cut -d" " -f 2 | cut -d"." -f 3)

    if [ x"$(cat  /etc/sysconfig/network-scripts/ifcfg-lo | grep TYPE)" = x"" ];
    then
        echo "TYPE=lookback" >> /etc/sysconfig/network-scripts/ifcfg-lo
    fi

    config_name=$1

cat << EOF > /etc/sysconfig/network-scripts/${config_name}
DEVICE="${config_name}"
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

which lxc-checkconfig
if [ $? -ne 0 ]; then
    LXC_VERSION=lxc-2.0.0.tar.gz
    download_file http://linuxcontainers.org/downloads/lxc/${LXC_VERSION}
    tar xf ${LXC_VERSION}
    cd ${LXC_VERSION%%.tar.gz}
    ./configure
    make
    make install
    cd -
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
fi

which lxc-checkconfig
print_info $? lxc-installed
config_output=$(lxc-checkconfig)
[[ $config_output =~ 'missing' ]] && print_info 1 lxc-checkconfig
[[ $config_output =~ 'missing' ]] || print_info 0 lxc-checkconfig

set -x

case $distro in 
    "fedora" )
        sed -i 's/type ubuntu-cloudimg-query/#type ubuntu-cloudimg-query/g' /usr/share/lxc/templates/lxc-ubuntu-cloud
        sed -i 's/xpJf/xpf/g' /usr/share/lxc/templates/lxc-ubuntu-cloud
        #cp /etc/lxc/default.conf /etc/lxc/default.conf_bk
        sed -i "s/lxcbr0/virbr0/g"  /etc/lxc/default.conf
        brtcl_exist=$(ip addr | grep virbr0)
        if [ x"$brtcl_exist" = ""x ]; then
            config_brctl virbr0
        fi
        $restart_service libvirtd.service
        $restart_service network.service
        ;;
    "centos" )
        sed -i 's/type ubuntu-cloudimg-query/#type ubuntu-cloudimg-query/g' /usr/local/share/lxc/templates/lxc-ubuntu-cloud
        brtcl_exist=$(ip addr | grep virbr0)
        if [ x"$brtcl_exist" = ""x ]; then
            config_brctl lxcbr0
        fi
        $restart_service libvirtd.service
        $restart_service network.service
        ;;
esac

distro_name=ubuntu
lxc-create -n $distro_name -t ubuntu-cloud -- -r vivid -T http://htsat.vicp.cc:808/docker-image/ubuntu-15.04-server-cloudimg-arm64-root.tar.gz
print_info $? lxc-create

lxc-ls

distro_exists=$(lxc-ls --fancy)
[[ "${distro_exists}" =~ $distro_name ]] && print_info 0 lxc-ls
[[ "${distro_exists}" =~ $distro_name ]] || print_info 1 lxc-ls

case $distro in
    "ubuntu" )
        echo "lxc.aa_allow_incomplete = 1"  >> /var/lib/lxc/${distro_name}/config
        sudo /etc/init.d/apparmor reload
        sudo aa-status
        ;;
esac

lxc-start --name ${distro_name} --daemon
result=$?

lxc_status=$(lxc-info --name $distro_name)
if [ "$(echo $lxc_status | grep $distro_name | grep 'RUNNING')" = "" ] && [ $result -ne 0 ]; then
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

lxc-stop --name $distro_name
print_info $? lxc-stop

lxc-execute -n $distro_name /bin/echo hello
temp_result=$?
print_info $temp_result lxc-execute
if [ $temp_result -eq 0 ];then
    lxc-stop --name $distro_name
    print_info $? lxc-stop
fi

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
