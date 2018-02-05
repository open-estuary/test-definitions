#!/bin/bash
#================================================================
#   Copyright (C) 2017. All rights reserved.
#   
#   文件名称：redis-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年11月22日
#   描    述：
#
#================================================================


set -x
export PS4='+{$LINENO:${FUNCNAME[0]}} '

basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../../../utils/sys_info.sh
. ../../../../utils/sh-test-lib

source ./redis.sh 

install_redis
redis_start 

sleep 2

redis_string_test 

redis_hash_test
redis_list_test
redis_set_test
redis_sortedset_test
redis_transaction_test 

redis_save_test 

redis_auth

redis_stop  -a
 redis_uninstall 

