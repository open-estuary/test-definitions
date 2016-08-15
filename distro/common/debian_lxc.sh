#!/bin/bash

pushd ./utils
. ./sys_info.sh
popd

CN_SOURCE_PATH1='deb http://ftp.cn.debian.org/debian sid main'
CN_SOURCE_PATH2='deb http://ftp.cn.debian.org/debian jessie-backports main'
echo $CN_SOURCE_PATH1 >> /etc/apt/sources.list
echo $CN_SOURCE_PATH2 >> /etc/apt/sources.list

apt-get update
apt-get upgrade -f
apt-get install lxc -y
apt-get install bridge-utils libvirt-bin debootstrap -y

whick lxc-checkconfig
if [ $? -ne 0 ]; then
    LXC_VERSION=lxc-2.0.0.tar.gz
    wget http://linuxcontainers.org/lxc/download/${LXC_VERSION}
    tar xf ${LXC_VERSION}
    cd ${LXC_VERSION%%.tar.gz}
    ./configure
    make
    make install
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
fi

which lxc-checkconfig
print_info $? lxc-installed
config_output=$(lxc-checkconfig)
[[ $config_output =~ 'missing' ]] && print_info 1 lxc-checkconfig
[[ $config_output =~ 'missing' ]] || print_info 0 lxc-checkconfig

set -x

case $distro in
    "debian")
    sed -i 's/type ubuntu-cloudimg-query/#type ubuntu-cloudimg-query/g' /usr/share/lxc/templates/lxc-ubuntu-cloud
    sed -i "s/lxcbr0/virbr0/g" /etc/lxc/default.conf
    brtcl_exist=$(ip addr | grep virbr0)
    if [ x"$brtcl_exist" = ""x ]; then
            config_brctl virbr0
    fi
    $restart_service libvirtd.service
    $restart_service network.service
    ;;
esac

apt-get install apparmor-profiles
/etc/init.d/apparmor reload
/etc/init.d/apparmor start

distro_name=mycontainer
lxc-create -n $distro_name -t /usr/share/lxc/templates/lxc-ubuntu-cloud -- -r vivid -T http://htsat.vicp.cc:808/docker-image/ubuntu-15.04-server-cloudimg-arm64-root.tar.gz

print_info $? lxc-create
lxc-ls

distro_exists=$(lxc-ls --fancy)
[[ "${distro_exists}" =~ $distro_name ]] && print_info 0 lxc-ls
[[ "${distro_exists}" =~ $distro_name ]] || print_info 1 lxc-ls

case $distro in
    "debian" )
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
