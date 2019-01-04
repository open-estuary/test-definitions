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
	
	grep -E "^authenticator: AllowAllAuthenticator" /etc/cassandra/default.conf/cassandra.yaml
    if [ $? -ne 0 ];then
        echo "authenticator: AllowAllAuthenticator" >> /etc/cassandra/default.conf/cassandra.yaml
    fi

        cassandra20_edit_config
        cassandra20_start_by_service 
    fi
}




function ccdriver_install(){
    
    yum install gcc -y
    yum install cassandra-cpp-driver -y
    yum install cassandra-cpp-driver-devel -y
    print_info $? install_cassandra_cpp_driver   
}

function ccdriver_uninstall(){

    yum remove -y cassandra-cpp-driver
    yum remove -y cassandra-cpp-driver-devel
    print_info $? uninstall_cassandra_cpp_driver
}


function ccdriver_sample_exec(){

    gcc -o sampleQuery connect.c -lcassandra
    print_info $? link_cassandra_dynamic_lib
jps
    su cassandra -c "./sampleQuery 2>&1 | grep -i error "
    if [ $? -eq 0 ];then
        print_info 1 cassandra_cpp_driver_proglme_exec
    else
        print_info 0 cassandra_cpp_driver_proglme_exec
    fi
        

}


