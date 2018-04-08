#!/bin/bash

#=================================================================
#   文件名称：twemproxy.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年01月24日
#   描    述：
#
#================================================================*/

source ../redis/redis.sh 

function twemproxy_install(){

    yum install -y twemproxy 
    print_info $? "install_twemproxy"


}

function redis_start_cluster(){

    if [ -z $1  ];then
        list="6379 6389 6399"
    else 
        list=$1
    fi
    ret=0
    for port in $list
    do
        redis_start $port
        if [ $? -ne 0 ];then
            let ret=$ret+1
        fi 
    done
    if [ $ret -eq 3 ];then
        true 
    else
        false
    fi 
    print_info $? "redis_cluster_start"


}

function twemproxy_edit_conf(){
    cpCmd=`which cp --skip-alias`
    $cpCmd -f ./twemproxy.conf /etc/twemproxy.yml 
}

function twemproxy_start(){
    
    systemctl start twemproxy.service
    print_info $? "twemproxy_start"
    sleep 2

}

function twemproxy_test(){

    redis-cli -p 22121 set testkey "testvalue"
    print_info $? "twemproxy_test_set"
    ret=`redis-cli -p 22121 get testkey`
    if [ x$ret == x"testvalue" ];then
        true
    else
        false
    fi 
    print_info $? "twemproxy_test_get"
}

function twemproxy_stop(){
    
    systemctl stop twemproxy.service
    print_info $? "twemproxy_stop"
}

function redis_cluster_stop(){

    redis_stop -a 
    print_info $? "twemproxy_stop_redis_cluster"

}

function twemproxy_uninstall(){

    yum remove -y twemproxy 
    print_info $? "twemproxy_uninstall"
}
