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
function debian_brctl()
{
HOST_INTERFACES="/etc/network/interfaces"
HOST_INTERFACES_BK="/etc/network/interfaces_bk"
BRIDGE_LOCAL_CONF="/etc/sysctl.d/bridge_local.conf"

    ip_segment=$(ip addr show `ip route | grep "default" | awk '{print $NF}'`| grep -o "inet [0-9\.]*" | cut -d" " -f 2 | cut -d"." -f 3)
    ip link set br0 down
    brctl delbr br0
    brctl addbr br0
    addr_show=$(ip addr show | grep br0)
    if [ x"$addr_show" = x""]; then
    printf_info 1 brctl_addbr_br0
    exit 0
    fi
    brctl addif br0 eth0 eth4
    if [ $? -ne 0 ]; then
    printf_info 1 brctl_addif
    exit 0
    fi
    cp $HOST_INTERFACES $HOST_INTERFACES_BK       
    cat /dev/null > $HOST_INTERFACES
    echo "auto lo br0" >> $HOST_INTERFACES
    echo "iface lo inet loopback" >> $HOST_INTERFACES
    echo "iface eth0 inet manual" >> $HOST_INTERFACES
    echo "iface eth4 inet manual" >> $HOST_INTERFACES
    echo "iface br0 inet dhcp" >> $HOST_INTERFACES
    echo "bridge_ports eth0 eth4" >> $HOST_INTERFACES
    
    if [ ! -e $BRIDGE_LOCAL_CONF ]; then
    touch $BRIDGE_LOCAL_CONF
    fi
    sed  '/exit/'d $BRIDGE_LOCAL_CONF
    echo "/etc/init.d/procps restart" >> $BRIDGE_LOCAL_CONF
    echo "exit 0" >> $BRIDGE_LOCAL_CONF
    
    ifup br0 
}
pushd ./utils
. ./sys_info.sh
popd
#deps on lxc bridge-utils libvirt-bin debootstrap
#deps on apparmor-profiles
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

config_output=$(lxc-checkconfig)
[[ $config_output =~ 'missing' ]] && print_info 1 lxc-checkconfig
[[ $config_output =~ 'missing' ]] || print_info 0 lxc-checkconfig

set -x
distro="debian"
case $distro in 
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
    "debian" )
        sed -i 's/type ubuntu-cloudimg-query/#type ubuntu-cloudimg-query/g' /usr/share/lxc/templates/lxc-ubuntu-cloud
            echo "debian brctl ############"
            #debian_brctl
        ;;
esac

rand=$(date +%s)
distro_name=mylxc$rand
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
    "debian" )
        echo "lxc.aa_allow_incomplete = 1"  >> /var/lib/lxc/${distro_name}/config
        /etc/init.d/apparmor reload
        /etc/init.d/apparmor start
        debian_brctl
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
expect $distro_name
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
