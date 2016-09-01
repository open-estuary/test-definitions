#!/bin/bash

common_brctl()
{
    local config_name=$2
    local network_scripts_dir=$1

    if [ x"$(cat  ${network_scripts_dir}/ifcfg-lo | grep TYPE)" = x"" ];
    then
        echo "TYPE=lookback" >> ${network_scripts_dir}/ifcfg-lo
    fi

    ip_segment=$(ip addr show `ip route | grep "default" | awk '{print $NF}'`| grep -o "inet [0-9\.]*" | cut -d" " -f 2 | cut -d"." -f 3)

cat << EOF > ${network_scripts_dir}/${config_name}
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

opensuse_brctl()
{
    local config_name=$2
    local network_scripts_dir=$1
    local dev=$(ip route | grep "default" | awk '{print $NF}')
    local ip_addr=$(ip addr show $dev | grep -o "inet [0-9\.]*" | cut -d" " -f 2)
    local ip_brd=${ip_addr%.*}.255

cat << EOF > ${network_scripts_dir}/${config_name}
STARTMODE='auto'
BOOTPROTO='static'
IPADDR="$ip_addr"
NETMASK="255.25.255.0"
BROADCAST="$ip_brd"
BRIDGE='yes'
BRIDGE_STP='off'
BRIDGE_FORWARDDELAY='0'
BRIDGE_PORTS="$dev"
EOF
}

debian_brctl()
{
    HOST_INTERFACES="/etc/network/interfaces"
    HOST_INTERFACES_BK="/etc/network/interfaces_bk"
    BRIDGE_LOCAL_CONF="/etc/sysctl.d/bridge_local.conf"

    ETH1=$(ip route | grep "default" | awk '{print $NF}')
    EHT2=$(ip addr | awk '/eth*/' | awk '!/inet/'| awk '!/link/'|awk 'NR==2'|awk -F: '{print $2}')

    local bridge=$1
    ip link set $bridge down
    brctl delbr $bridge
    brctl addbr $bridge

    addr_show=$(ip addr show | grep $bridge)
    if [ x"$addr_show" = x"" ]; then
        printf_info 1 brctl_addbr_$bridge
    fi

    brctl addif $bridge $ETH1
    if [ $? -ne 0 ]; then
        printf_info 1 brctl_addif
    fi

    cp $HOST_INTERFACES $HOST_INTERFACES_BK
    cat /dev/null > $HOST_INTERFACES

    echo "auto lo $bridge" >> $HOST_INTERFACES
    echo "iface lo inet loopback" >> $HOST_INTERFACES
    echo "iface eth0 inet manual" >> $HOST_INTERFACES
    echo "iface $ETH2 inet manual" >> $HOST_INTERFACES
    echo "iface $bridge inet dhcp" >> $HOST_INTERFACES
    echo "bridge_ports eth0 $ETH2" >> $HOST_INTERFACES

    if [ ! -e $BRIDGE_LOCAL_CONF ]; then
        touch $BRIDGE_LOCAL_CONF
    fi

    sed  '/exit/d' $BRIDGE_LOCAL_CONF
    echo "/etc/init.d/procps restart" >> $BRIDGE_LOCAL_CONF
    echo "exit 0" >> $BRIDGE_LOCAL_CONF

    ifup $bridge
}

brctl_config()
{
    local bridge=$1
    local config_name=ifcfg-$bridge
    local NETWORK_SCRIPTS_DIR="/etc/sysconfig/network-scripts"

    case $distro in
        opensuse)
            NETWORK_SCRIPTS_DIR="/etc/sysconfig/network"
            opensuse_brctl $NETWORK_SCRIPTS_DIR $config_name
            ;;
        ubuntu)
            echo "ubuntu brctl ############"
            ;;
        debian)
            echo "debian brctl ############"
            debian_brctl $bridge
            ;;
        *)
            common_brctl $NETWORK_SCRIPTS_DIR $config_name
            ;;
    esac
}

set -x

pushd ./utils
. ./sys_info.sh
popd

# -- bridge network -----------------------------------------------------------
BRIDGE_NAME=virbr0
brtcl_exist=$(ip addr | grep $BRIDGE_NAME)
if [ x"$brtcl_exist" = x"" ]; then
    brctl_config $BRIDGE_NAME
    $restart_service libvirtd.service
    $restart_service network.service
fi

sed -i "s/lxcbr0/${BRIDGE_NAME}/g"  /etc/lxc/default.conf

# -- lxc-checkconfig ----------------------------------------------------------
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
if [[ $config_output =~ 'missing' ]]; then
    print_info 1 lxc-checkconfig
else
    print_info 0 lxc-checkconfig
fi

# -- lxc-create ---------------------------------------------------------------
LXC_TEMPLATE=/usr/share/lxc/templates/lxc-ubuntu-cloud

if [ ! -e ${LXC_TEMPLATE}.origin ];
then
    cp ${LXC_TEMPLATE}{,.origin}
else
    cp ${LXC_TEMPLATE}{.origin,}
fi

sed -i 's/xpJf/xpf/g' $LXC_TEMPLATE
sed -i 's/^type ubuntu-cloudimg-query/#&/g' $LXC_TEMPLATE
if [ $distro = "opensuse" ]; then
    sed -i '/"\$CLONE_HOOK_FN"/s/"\${cloneargs\[@]}"/& "--nolocales=true"/' $LXC_TEMPLATE
fi

rand=$(date +%s)
container=mylxc$rand
lxc-create -n $container -t ubuntu-cloud -- -r vivid -T http://htsat.vicp.cc:808/docker-image/ubuntu-15.04-server-cloudimg-arm64-root.tar.gz
print_info $? lxc-create

# -- lxc-ls -------------------------------------------------------------------
lxc-ls

distro_exists=$(lxc-ls --fancy)
if [[ "${distro_exists}" =~ $container ]]; then
    print_info 0 lxc-ls
else
    print_info 1 lxc-ls
fi

# -- lxc-start ----------------------------------------------------------------
LXC_CONFIG=/var/lib/lxc/${container}/config

case $distro in
    "ubuntu" | "debian" )
        /etc/init.d/apparmor reload
        aa-status
        ;;
    "opensuse" )
        sed -i -e "/lxc.network/d" $LXC_CONFIG
cat << EOF >> $LXC_CONFIG
lxc.network.type = veth
lxc.network.link = $BRIDGE_NAME
lxc.network.flags = up
EOF
        $reload_service apparmor
        ;;
    * )
        $reload_service apparmor
        ;;
    "debian" )
        echo "lxc.aa_allow_incomplete = 1"  >> /var/lib/lxc/${distro_name}/config
        /etc/init.d/apparmor reload
        /etc/init.d/apparmor start
        debian_brctl
        ;;
esac

echo "lxc.aa_allow_incomplete = 1"  >> $LXC_CONFIG

lxc-start --name ${container} --daemon
result=$?

# -- lxc-info -----------------------------------------------------------------
lxc_status=$(lxc-info --name $container)
if [[ "$(echo $lxc_status | grep $container | grep 'RUNNING')" = "" && $result -ne 0 ]]
then
    print_info 1 lxc-start
else
    print_info 0 lxc-start
fi

# -- lxc-attach ---------------------------------------------------------------
/usr/bin/expect <<EOF
set timeout 400
spawn lxc-attach -n $container
expect $container
send "exit\r"
expect eof
EOF
print_info $? lxc-attach

# -- lxc-execute --------------------------------------------------------------
lxc-attach -n $container -- /bin/echo hello
print_info $? lxc-execute

# -- lxc-stop -----------------------------------------------------------------
lxc-stop --name $container
print_info $? lxc-stop

# -- lxc-destroy --------------------------------------------------------------
lxc-destroy --name $container
print_info $? lxc-destory

