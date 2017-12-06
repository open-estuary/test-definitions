#!/bin/bash

#=================================================================
#   文件名称：percona-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年11月30日
#   描    述：
#
#================================================================*/


basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../lib/sh-test-lib
. ../../utils/sys_info.sh

source ./percona.sh 

set -x

export PS4='+{$LINENO:${FUNCNAME[0]}} '

mysql_transaction 
exit 


percona_install
close_firewall_seLinux 
percona_start 
mysql_client
mysql_create
mysql_alter
mysql_drop
mysql_load_data 
mysql_select
mysql_insert



#percona_uninstall
