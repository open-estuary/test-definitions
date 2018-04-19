#!/bin/bash

#=================================================================
#   文件名称：findbugs-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月26日
#   描    述：
#
#================================================================*/


basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh

source ./findbugs.sh 
 
set -x
export PS4='+{$LINENO:${FUNCNAME[0]}} '

install_findbugs
findbugs_test
uninstall_findbugs
