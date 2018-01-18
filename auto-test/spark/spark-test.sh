#!/bin/bash

#=================================================================
#   文件名称：spark-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年01月05日
#   描    述：
#
#================================================================*/


basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../lib/sh-test-lib
. ../../utils/sys_info.sh
. ../../utils/sshpasswd.sh 
source ./spark.sh 

set -x

export PS4='+{$LINENO:${FUNCNAME[0]}} '
spark_download
#spark_login_no_passwd
ssh_no_passwd
#spark_slave_host
spark_deploy_cluster
spark_start_cluster

spark_SparkContext_test
spark_RDD_test 


spark_stop_cluster
