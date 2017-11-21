#!/bin/bash

basedir=$(cd `dirname $0` ; pwd)
cd $basedir
. ../../utils/sys_info.sh
. ../../utils/sh-test-lib

source ./mongodb-tools.sh 
source ./mongodb.sh 

isServerRunning
install_mongo-tools

mongo_mongostat
mongo_dump_restore


