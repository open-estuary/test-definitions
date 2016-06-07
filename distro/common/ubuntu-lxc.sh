#!/bin/bash

pushd ./utils
. ./sys_info.sh
popd

function print_info()
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

config_output=$(lxc-checkconfig)
[[ $config_output =~ 'missing' ]] && print_info 1 lxc-checkconfig
[[ $config_output =~ 'missing' ]] || print_info 0 lxc-checkconfig

lxc-create -n $distro -t ubuntu-cloud -- -r vivid -T http://192.168.1.108:8083/docker-image/ubuntu-15.04-server-cloudimg-arm64-root.tar.gz
print_info $? lxc-create

distro_exists=$(lxc-ls --fancy)
[[ "${distro_exists}" =~ $distro ]] && print_info 0 lxc-ls
[[ "${distro_exists}" =~ $distro ]] || print_info 1 lxc-ls

echo "lxc.aa_allow_incomplete = 1"  >> /var/lib/lxc/${distro}/config

lxc-start --name $distro --daemon
if [ $? -eq 0 ]; then
    lxc-info --name $distro
    if [ $? -ne 0 ]; then
        print_info 1 lxc-info
    fi
fi

lxc_status=$(lxc-info --name $distro)
if [ "$(echo $lxc_status | grep $distro | grep 'RUNNING')" = ""x ]; then
    print_info 1 lxc-start
else
    print_info 0 lxc-start
fi

lxc-execute -n $distro /bin/echo hello
print_info $? lxc-execute

#lxc-attach -n $distro
#print_info $? lxc-attach

lxc-stop --name $distro
print_info $? lxc-stop

lxc-destroy --name $distro
print_info $? lxc-destory


#$install_commands lxc-tests
#install_results=$?
#print_info $install_results install-lxc-tests
#if [ $install_results -eq 0 ]; then
#   for i in /usr/bin/lxc-test-*
#   do 
#       $i
#       print_info $? "$i"
#   done
#fi
