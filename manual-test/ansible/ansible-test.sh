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

source ./ansible.sh 
set -x
export PS4='+{$LINENO:${FUNCNAME[0]}} '

install_ansible 

./../../utils/sshpasswd-ex.sh oneway $1 

ansible_system_test
ansible_file_test


