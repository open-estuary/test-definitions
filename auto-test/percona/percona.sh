#!/bin/bash

#=================================================================
#   文件名称：percona.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月07日
#   描    述：
#
#================================================================*/


function percona_uninstall(){
    
    yum remove -y AliSQL*
    yum remove -y mariadb*
    yum remove -y mysql*
    yum remove -y Percona*
    print_info $? "percona uninstall"

}

function percona_install(){
    
    yum install -y git 
    yum install -y Percona-Server-server-56
    if [ $? -ne 0  ];then
        percona_uninstall
        yum install -y Percona-Server-server-56
        if [ $? -ne 0  ];then
            print_info 1 "install percona server"
            exit 1
        fi 
    else
        print_info 0 "install percona server"
    fi
    export LANG="en_US.UTF-8"

    yum info Percona-Server-server-56 > tmpinfo
    version=`cat tmpinfo | grep Version |  cut -d : -f2`
    repo=`cat tmpinfo | grep "From repo" | cut -d : -f 2`
    if [ $version == "5.6.35" -a $repo == "Estuary"  ];then
        true
    else
        false
    fi
    print_info $? "percona version is right"
    rm -f tmpinfo

}

function percona_modify_system_args(){

    echo 
}

function percona_start(){
:<<eof
    if [ -z  $1   ];then
        port=3306
    else
        port=$1
    fi 
    dir="/percona/db/$port"
    mkdir -p  $dir
    alias cp='cp'
    cp -f /etc/my.cnf  ${dir}/my.cnf
    mkdir -p ${dir}/{log,run}
    sed -i "s?^datadir.*?datadir=${dir}?" ${dir}/my.cnf
    sed -i "s?^socket.*?socket=${dir}/mysql\.sock?" ${dir}/my.cnf 
    sed -i "s?^log-error.*?log-error=${dir}/log/mysqld\.log?" ${dir}/my.cnf 
    sed -i "s?^pid-file.*?pid-file=${dir}/run/mysqld\.pid?" ${dir}/my.cnf 
    
    mysqld_safe 
eof

    case $1 in 
        1)
            systemctl start mysqld.service
            ;;
        2)
            mysqld_safe --defaults-file=/etc/my.cnf &
            ;;
        3)
            mysqld --defaults-file=/etc/my.cnf --user=mysql &
            ;;
        *)
            systemctl start mysqld.service
            ;;
    esac

}

function percona_stop(){
    
    case $1 in 
        2)
            systemctl stop mysqld.service
            ;;
        *)
            mysqladmin shutdown
            ;;
    esac

}
