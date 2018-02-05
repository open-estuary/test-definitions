#!/bin/bash

#=================================================================
#   文件名称：twemproxy-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年01月24日
#   描    述：
#
#================================================================*/


basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../../../lib/sh-test-lib
. ../../../../utils/sys_info.sh
set -x

export PS4='+{$LINENO:${FUNCNAME[0]}} '

source ../redis/redis.sh 
source ./twemproxy.sh

twemproxy_install 
install_redis 

list="6379 6389 6399"
redis_start_cluster "$list" 
twemproxy_edit_conf 
twemproxy_start
twemproxy_test
twemproxy_stop 
redis_cluster_stop

twemproxy_uninstall 



