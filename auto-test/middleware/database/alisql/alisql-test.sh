#!/bin/bash

#=================================================================
#   文件名称：alisql-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月27日
#   描    述：
#
#================================================================*/

basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../../../lib/sh-test-lib
. ../../../../utils/sys_info.sh

source ./alisql.sh 
source ./../percona/mysql.sh 
#set -x
#export PS4='+{$LINENO:${FUNCNAME[0]}} '
outDebugInfo
cleanup_all_database
alisql_install
alisql_start_custom
version=alisql 
mysql_client
mysql_create
mysql_alter
mysql_drop
mysql_load_data 
mysql_select
mysql_insert

mysql_transaction 

#mysql_log
mysql_innodb

alisql_stop_custom 
cleanup_all_database

