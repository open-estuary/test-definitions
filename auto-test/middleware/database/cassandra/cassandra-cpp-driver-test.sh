#!/bin/bash

#=================================================================
#   文件名称：cassandra-cpp-driver-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月26日
#   描    述：
#
#================================================================*/


basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../../../lib/sh-test-lib
. ../../../../utils/sys_info.sh

source ./cassandra-cpp-driver.sh 
source ./cassandra.sh 
set -x
export PS4='+{$LINENO:${FUNCNAME[0]}} '

ccdriver_install
ccdriver_server_isRunning 
ccdriver_sample_exec

cassandra20_stop_by_service
cassandra_uninstall 
ccdriver_uninstall 

