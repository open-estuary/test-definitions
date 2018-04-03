#!/bin/bash

#=================================================================
#   文件名称：nginx-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年02月05日
#   描    述：
#
#================================================================*/




basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../../../lib/sh-test-lib
. ../../../../utils/sys_info.sh

source ./nginx.sh 
#set -x
#export PS4='+{$LINENO:${FUNCNAME[0]}} '
outDebugInfo

nginx_install
nginx_start 
nginx_base_fun

test_geoip_mod 

nginx_stop 

nginx_remove
