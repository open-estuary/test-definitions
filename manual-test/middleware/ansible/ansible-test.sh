#!/bin/bash

#=================================================================
#   文件名称：ansible-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年01月03日
#   描    述：
#
#================================================================*/



basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../lib/sh-test-lib
. ../../utils/sys_info.sh 
. ../../utils/sshpasswd.sh 

source ./ansible.sh 
set -x
export PS4='+{$LINENO:${FUNCNAME[0]}} '

install_ansible 
if [ -z $1 ];then
    hostfile='./hostfile'
else
    hostfile=$1
fi 
ansible_host_file $hostfile 
#exit
ansible_system_test
ansible_file_test
ansible_command_test
ansible_package_test

ansible_network_test




