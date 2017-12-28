#!/bin/bash

#=================================================================
#   文件名称：cassandra-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月25日
#   描    述：
#
#================================================================*/


basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../lib/sh-test-lib
. ../../utils/sys_info.sh

source ./cassandra.sh 
set -x
export PS4='+{$LINENO:${FUNCNAME[0]}} '

cassandra20_install
cassandra20_edit_config
cassandra20_start_by_service

cassandra20_sql_ddl

cassandra20_stop_by_service

#cassandra20_uninstall


