#!/bin/bash

#=================================================================
#   文件名称：nodejs-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年11月28日
#   描    述：
#
#================================================================*/


basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh

if [ "${ci_http_addr}"x = "http://172.19.20.15:8083"x ];then
	    export http_proxy="http://172.19.20.11:3128"
	    export https_proxy="http://172.19.20.11:3128"
fi

source ./nodejs.sh 

nodejs_install
nodejs_npm
nodejs_fs_test
nodejs_uninstall
