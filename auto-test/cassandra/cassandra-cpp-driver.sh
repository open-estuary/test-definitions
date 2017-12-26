#!/bin/bash

#=================================================================
#   文件名称：cassandra-cpp-driver.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月26日
#   描    述：
#
#================================================================*/

source ./cassandra.sh 

function ccdriver_install(){
    
    yum install cassandra-cpp-driver -y 
    print_info $? "install cassandra cpp driver "

    export LANG=en_US.UTF8 
    yum info cassandra-cpp-driver > tmp.info 
    local version=`grep Version tmp.info | cut -d : -f 2`
    local repo=`grep "From repo" tmp.info | cut -d : -f 2`

    if [ $version = "1.7.0" -a $repo = "Estuary" ];then
        true
    else
        false
    fi 
    print_info $? "cassandra cpp driver version and repo is right"
    
}


function ccdriver_sample_exec(){

    gcc -o sampleQuery connect.c -lcassandra
    print_info $? "use cassandra dynamic lib expline "

    ./sampleQuery 2>&1 | grep -i error 
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "cassandra cpp driver proglme exec "    

}


