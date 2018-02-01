#!/bin/bash

#=================================================================
#   文件名称：zk-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年01月23日
#   描    述：
#
#================================================================*/


basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../lib/sh-test-lib
. ../../utils/sys_info.sh
. ../../utils/sshpasswd.sh 
source ./zk.sh 
set -x
export PS4='+{$LINENO:${FUNCNAME[0]}} '

zk_install_standalone
zk_install_c_client
zk_start

zk_base_operoter
zk_admin_test

zk_stop 


