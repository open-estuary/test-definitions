#!/bin/bash

#=================================================================
#   文件名称：ycsb-test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月27日
#   描    述：
#
#================================================================*/

function install_ycsb(){

    yum install -y ycsb java-1.8.0-openjdk
    print_info $? "install ycsb"

    export LANG=en_US.UTF8
    yum info ycsb > tmp.info 
    local version=`grep Version tmp.info | cut -d : -f 2`
    local repo=`grep "From repo" tmp.info | cut -d : -f 2`
    if [ $version = "0.12.0" -a $repo = "Estuary" ];then
        true
    else
        false
    fi 
    print_info $? "ycsb version is right"
}

function ycsb_env(){
    
    local path=`rpm -ql ycsb | grep 'ycsb.sh'`
    local HOME=`dirname \`dirname $path \``
    grep YCSB_HOME ~/.bashrc 
    if [ $? -ne 0 ];then
        echo "export YCSB_HOME=$HOME" >> ~/.bashrc 
        echo 'export PATH=$PATH:$YCSB_HOME/bin' >> ~/.bashrc 
    fi 
    
    grep YCSB_HOME ~/.bashrc 
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "ycsb add YCSB_HOME env"
    
}

function uninstall_ycsb(){
    yum remove -y ycsb
    print_info $? "uninstall ycsb"
    sed -i /'YCSB_HOME'/d ~/.bashrc 

}

install_ycsb
ycsb_env

uninstall_ycsb
