#!/bin/sh
# Copyright (C) 2017-8-29, Linaro Limited.
#qperf is a tool for testing bandwidth and latency
# Author: mahongxin <hongxin_228@163.com>

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
function mariadb_install(){
    yum install -y  mariadb-server
    ret=$?
    print_info $ret "install_mariadb"
    if [ $ret -ne 0 ];then
        echo
        echo "install mariadb failed"
        echo
        exit 1
    fi 
}

function mariadb_start(){
    systemctl start mariadb 
    ret=$?
    print_info $ret "start_mariadb"
    if [ $ret -ne 0 ];then
        echo 
        echo "start mariadb failed"
        echo 
        exit 1
    fi 
}

function mariadb_stop(){
    systemctl stop mariadb 
    print_info $? "stop_mariadb"
}

function mariadb_remove(){
    systemctl stop mariadb 
    yum remove -y mariadb mariadb-server
    print_info $? "remove_mariadb"
}

