#! /bin/bash

basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh
dist=`dist_name`
echo $dist

#set -x 
#export PS4='+{$LINENO:${FUNCTION[0]}} '
outDebugInfo



function memcached_install(){
    yum install -y memcached
    print_info $? "memcacehd_install"

    yum install -y libevent python2-pip
    print_info $? "memcacehd_preinstall"

    pip install -q python-memcached
    print_info $? "memcached_client_install"

    yum install -y nmap-ncat 
}

function memcached_start_by_command(){

    useradd memtest
    memcached -d -p 11211 -m 64m -u memtest 
    ps -ef |grep "memcached -d -p" | grep -v grep
    print_info $? "memcached_start"
}

function memcached_start_by_service(){

    systemctl start memcached.service 
    ps -ef | grep '/usr/bin/memcached' | grep -v grep 

    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "memcached_start_by_systemd"
}


function memcached_conn(){
    res=`echo "stats" | nc localhost 11211`
    if [ $? -eq 0 ] ; then
        lava-test-case "memcache_connect" --result pass
    else
        lava-test-case "memcache_connect" --result fail
    fi 

}

function memcached_exec(){
    echo "-------begin memcache innter function------"
    echo 
    python ./mc.py
    echo 
    echo "-------stop memcached innter function------"
}

function memcached_stop_by_service(){
   systemctl stop memcached.service 
   ps -ef | grep '/usr/bin/memcached' | grep -v grep 
   if [ $? -eq 0 ];then
       false
   else
       true
   fi
   print_info $? "memcached_stop_service_by_systemd"
}

function memcached_stop_by_command(){
    
    pid=`ps -ef | grep '/usr/bin/memcached' | grep -v grep | awk {'print $2'}`
    if [ $? -eq 0 ];then
        kill -9 $pid
    fi 
    ps -ef | grep '/usr/bin/memcached' | grep -v grep 
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "memcached_stop_service_by_command"

}



function memcached_uninstall(){
    yum remove -y memcached
    print_info $? "memcached_uninstall"
}

memcached_install
memcached_start_by_service
memcached_conn
memcached_exec
memcached_stop_by_service

memcached_start_by_service
memcached_stop_by_command 

memcached_uninstall
