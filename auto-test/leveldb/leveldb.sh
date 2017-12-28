#!/bin/bash

#=================================================================
#   文件名称：leveldb.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月26日
#   描    述：
#
#================================================================*/

function install_leveldb(){

    yum install -y leveldb  leveldb-devel
    print_info $? "install leveldb "

    yum info leveldb > tmp.info 
    local version=`grep Version tmp.info | cut -d : -f 2`
    local repo=`grep "From repo" tmp.info | cut -d : -f 2`
    if [ $version = "1.20" -a $repo = "Estuary" ];then
        true
    else
        false
    fi 
    print_info $? "leveldb version is right"

}

function install_plyvel(){

    yum install -y python-pip 
    pip install plyvel
    python -c "import plyvel"
    if [ $? -ne 0 ];then
        print_info 1 "install plyvel"
        exit 1
    fi
    print_info 0 "install plyvel"

}

function uninstall_leveldb(){
    
    yum remove -y leveldb
    print_info $? "uninstall leveldb"
    pip uninstall -y plyvel 
    print_info $? "uninstall plyvel of python package"

}


function leveldb_test(){
    python ./leveldb-test.py 
}


