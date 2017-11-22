#!/bin/bash



basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../utils/sh-test-lib
. ../../utils/sys_info.sh

source ./mongocdriver.sh 
source ./mongodb.sh 


isServerRunning 
install_c_driver

mongo_c_driver_base



