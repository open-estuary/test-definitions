#!/bin/bash

#=================================================================
#   文件名称：alisql.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年11月28日
#   描    述：
#
#=================================================================

function alisql_uninstall(){

    yum remove -y mariadb*
    yum remove -y mysql*
    yum remove -y percona*
    yum remove -y AliSQL*
}

function alisql_install(){
    
    yum install -y AliSQL-server
    if [ $? -eq 0 ];then
        lava-test-case "AliSQL-server install" --result pass
    else
        alisql_uninstall
        yum install -y AliSQL-server
        if [ $? -ne 0 ];then
            lava-test-case "AliSQL-server install" --result fail
            exit 1
        fi
    fi
    export LANG=en_US.UTF8
    yum info AliSQL-server > tmp.info
    local version=`grep Version tmp.info | cut -d : -f 2`
    local repo=`grep "From repo" tmp.info | cut -d : -f 2`
    if [ $version = "5.6.32" -a $repo = "Estuary" ];then
        true
    else
        false
    fi 
    print_info $? "alisql version is right"

}

function alisql_start_custom(){

    if [ -z $1 ];then
        port=3306
    else
        port=$1
    fi 
    local base="/mysql/$port"
    
    rm -rf ${base}

    mkdir -p ${base}/{data,run,log}
    cp -f ./my.cnf $base
    sed -i s"/3306/$port/" ${base}/my.cnf 
    touch ${base}/run/mysqld.pid 
    touch ${base}/log/mysqld.log
    chown -R mysql:mysql ${base} 
    ln -s ${base}/my.cnf ~/.my.cnf
    mysql_install_db --defaults-file=${base}/my.cnf --user=mysql --force 
    if [ $? -ne 0 ];then 
        echo "alisql initilized failed"
        exit 1
    fi 
    mysqld_safe --defaults-file=${base}/my.cnf --user=mysql & 
    local pid=$!
    sleep 3
    ps -ef | grep $pid 
    if [ $? -ne 0 ];then
        echo "alisql can't start success"
        exit 1
    fi 
}

function alisql_stop_custom(){
    
    mysqladmin shutdown 
    ps -ef | grep mysqld | grep -v grep 
    if [ $? -eq 0 ];then
        false
    else
        true
    fi 
    print_info $? "alisql stop server by command"

    rm -f ~/.my.cnf
}

function alisql_sequece(){

#TODO
echo 
}
