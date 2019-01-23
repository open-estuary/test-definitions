#!/bin/bash


basedir=$(cd `dirname $0`;pwd)
cd $basedir

. ../../../../utils/sys_info.sh 

. ../../../../utils/sh-test-lib

source ./mongodb-debian.sh 

#set -x
#export PS4='+$LINENO:$FUNCTION[0] '
outDebugInfo
install_mongodb

mongodb_client
mongodb_shutdown

sleep 5 

mongodb_start_by_service
mongodb_stop_by_service


mongodb_uninstall




