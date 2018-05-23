#!/bin/bash

#=================================================================
#   文件名称：scala-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年01月10日
#   描    述：
#
#================================================================*/


basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../../../lib/sh-test-lib
. ../../../../utils/sys_info.sh

source ./scala.sh 

#set -x

#export PS4='+{$LINENO:${FUNCNAME[0]}} '

outDebugInfo
scala_install 
scala_env_path 
scala_test_if
scala_test_for 
scala_test_string
scala_test_collection

