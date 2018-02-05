#! /bin/bash

set -x
export PS4='+{$LINENO:${FUNCNAME[0]}} '

basedir=$(cd `dirname $0`;pwd)
cd $basedir
export basedir

. ../../../../utils/sys_info.sh
. ../../../../utils/sh-test-lib

. ./hive.sh


hive_start_hadoop 
hive_install 
hive_init

hive_base_client_command

hive_inner_table 
hive_outer_table
hive_partitioned_table
hive_bucket_table
#hive_uninstall

hadoop_stop_all 
