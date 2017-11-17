#!/bin/bash


basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../utils/sys_info.sh
. ../../utils/sh-test-lib

source ./mongodb.sh 


install_mongodb
mongodb_start
mongodb_client

