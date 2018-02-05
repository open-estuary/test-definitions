#!/bin/bash


basedir=$(cd `dirname $0`;pwd)
cd $basedir

. ../../../../utils/sys_info.sh 

. ../../../../utils/sh-test-lib

source ./mongodb.sh 

set -x
export PS4='+$LINENO:$FUNCTION[0] '
install_mongodb
mongodb_start


mongodb_client
mongodb_shutdown

mongodb_start_by_service
mongodb_stop_by_service

mongodb_uninstall




