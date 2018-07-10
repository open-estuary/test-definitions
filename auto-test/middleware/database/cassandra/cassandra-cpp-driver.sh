#!/bin/bash

#=================================================================
#   文件名称：cassandra-cpp-driver.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月26日
#   描    述：
#
#================================================================*/

source ./cassandra.sh 

function ccdriver_server_isRunning(){


    which cassandra && true || false 
    if [ $? -ne 0 ];then
        cassandra20_install
        cassandra20_edit_config
        cassandra20_start_by_service 
        pgrep -U cassandra && true || false 
        if [ $? -eq 0 ];then 
            return 0
        else
            exit 1
        fi 

    fi 

    pid=`pgrep -U cassandra `
    if [ $? -eq 0 ];then
        kill -9 $pid
        sleep 3
    fi
    cassandra20_edit_config 
    grep -E "^authenticator: AllowAllAuthenticator" /etc/cassandra/default.conf/cassandra.yaml 
    if [ $? -ne 0 ];then 
        echo "authenticator: AllowAllAuthenticator" >> /etc/cassandra/default.conf/cassandra.yaml 
    fi 
    
    cassandra20_start_by_service
}




function ccdriver_install(){
    
    yum install cassandra-cpp-driver -y
    yum install gcc -y
    print_info $? "install_cassandra_cpp_driver "

    yum install cassandra-cpp-driver-devel -y 
    export LANG=en_US.UTF8 
    yum info cassandra-cpp-driver > tmp.info 
    local version=`grep Version tmp.info | cut -d : -f 2`
    local repo=`grep "From repo" tmp.info | cut -d : -f 2`

    if [ $version = "2.7.0" -a $repo = "Estuary" ];then
        true
    else
        false
    fi 
    print_info $? "cassandra_cpp_driver_version_and_repo_is_right"
    
}

function ccdriver_uninstall(){

    yum remove -y cassandra-cpp-driver 
    print_info $? "uninstall_cassandra_cpp_driver"
}


function ccdriver_sample_exec(){

    gcc -o sampleQuery connect.c -lcassandra
    print_info $? "link_cassandra_dynamic_lib "
jps
    su cassandra -c "./sampleQuery 2>&1 | grep -i error "
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "cassandra_cpp_driver_proglme_exec "    

}


