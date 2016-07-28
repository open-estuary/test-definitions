#!/bin/bash

pushd ./utils
. ./sys_info.sh
popd

config_output=$(lxc-checkconfig)
[[ $config_output =~ 'missing' ]] && print_info 1 lxc-checkconfig
[[ $config_output =~ 'missing' ]] || print_info 0 lxc-checkconfig

distro_name=ubuntu
lxc-create -n $distro_name -t ubuntu-cloud -- -r vivid -T http://htsat.vicp.cc:808/docker-image/ubuntu-15.04-server-cloudimg-arm64-root.tar.gz
print_info $? lxc-create

distro_exists=$(lxc-ls --fancy)
[[ "${distro_exists}" =~ $distro_name ]] && print_info 0 lxc-ls
[[ "${distro_exists}" =~ $distro_name ]] || print_info 1 lxc-ls

echo "lxc.aa_allow_incomplete = 1"  >> /var/lib/lxc/${distro}/config

lxc-start --name $distro_name --daemon
result=$?

lxc_status=$(lxc-info --name $distro_name)
if [ "$(echo $lxc_status | grep $distro_name | grep 'RUNNING')" = ""x -a $result -ne 0 ]; then
    print_info 1 lxc-start
else
    print_info 0 lxc-start
fi

string=$(echo `lxc-execute -n $distro_name /bin/echo hello` | grep "ailed")
if [ x"$string" != x"" ]; then
    print_info 1 lxc-execute
else
    print_info 0 lxc-execute
fi

lxc-attach -n $distro_name
print_info $? lxc-attach

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
