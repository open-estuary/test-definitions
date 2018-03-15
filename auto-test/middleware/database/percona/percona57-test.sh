#!/bin/bash

#=================================================================
#   文件名称：percona-test-57.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月11日
#   描    述：
#
#================================================================*/


basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../../../lib/sh-test-lib
. ../../../../utils/sys_info.sh

source ./percona57.sh 
source ./mysql.sh 

set -x

export PS4='+{$0:$LINENO:${FUNCNAME[0]}} '
cleanup_all_database 

percona57_install
percona57_start

percona57_password 

mysql_client
mysql_create
mysql_alter
mysql_drop
mysql_load_data
mysql_select
mysql_insert

mysql_transaction
mysql_log
mysql_innodb

percona57_stop 
percona57_replication
percona57_custom_stop 

#percona57_remove
cleanup_all_database
