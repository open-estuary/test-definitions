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
    print_info $? "percona_uninstall"
    exit 
}

function percona_install(){
    
    yum install -y git 
    yum install -y Percona-Server-server-56
    if [ $? -ne 0  ];then
        percona_uninstall
        yum install -y Percona-Server-server-56
        if [ $? -ne 0  ];then
            print_info 1 "install_percona_server"
            exit 1
        fi 
    else
        print_info 0 "install_percona_server"
    fi
    export LANG="en_US.UTF-8"

    yum info Percona-Server-server-56 > tmpinfo
    version1=`cat tmpinfo | grep Version |  cut -d : -f2`
    repo=`cat tmpinfo | grep "From repo" | cut -d : -f 2`
    if [ x"$version1" == x"5.6.35" -a x"$repo" == x"Estuary"  ];then
        true
    else
        false
    fi
    print_info $? "percona_version_is_right"
    rm -f tmpinfo
    export version=` tr -d [:space:] "percona-$version1-$repo"`
}

function percona_modify_system_args(){

    echo 
}

function percona_start(){
    systemctl start mysqld.service
}

function percona_stop(){
    
    systemctl stop mysqld.service
}

function percona_clean_ps(){

    ps -ef | grep mysqld |grep -v grep | awk {'print $2'} | xargs kill -9  2>&1 >/dev/null 

}

function percona_start_stop_test(){

    # 使用systemd的方式来启动percona
    
    percona_clean_ps
    systemctl start mysqld.service
    ps -ef | grep mysqld_safe | grep -v grep
    if [ $? -eq 0 ];then
        true
    else
        
        false
    fi
    print_info $? "mysql_use_systemctl_start "

    systemctl stop mysqld.service 
    ps -ef | grep mysqld  | grep -v grep
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql_use_systemctl_stop"
    percona_clean_ps

    # 2直接使用mysqld_safe 来启动mysql
    mysqld_safe --defaults-file=/etc/my.cnf &
    sleep 2
    ps -ef | grep mysqld | grep -v grep 
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql_use_mysqld_safe_to_start"

    mysqladmin --defaults-file=/etc/my.cnf shutdown 
    ps -ef | grep mysqld | grep -v grep
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql_use_mysqladmin_to_stop"

    percona_clean_ps
    # 3 使用mysqld来启动 ，基本不使用该方式
    mysqld --defaults-file=/etc/my.cnf --user=mysql &
    sleep 2
    ps -ef | grep mysqld | grep -v grep 
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql_use_mysqld_to_start"

    mysqladmin --defaults-file=/etc/my.cnf shutdown 
    ps -ef | grep mysqld | grep -v grep 
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql_use_mysqladmin_to_stop_server"

}


function mysql_muti_start(){

    if [ $# -ge 1 ];then
        port=$1
    else
        port=3306
    fi
    basedir="/percona/$port"
    mkdir -p $basedir/{data,log,run}
    cp ./my.cnf $basedir
    
    touch $basedir/log/mysqld.log 
    sed -i s/3306/$port/ $basedir/my.cnf 
    sed -i s?"datadir.*"?"datadir=$basedir/data"? ${basedir}/my.cnf
    sed -i s?"socket.*"?"socket=$basedir/data/mysql.sock"? ${basedir}/my.cnf
    sed -i s?"log-error.*"?"log-error=$basedir/log/mysqld.log"? ${basedir}/my.cnf
    sed -i s?"pid-file.*"?"pid-file=$basedir/run/mysqld.pid"? ${basedir}/my.cnf
    
    chown -R mysql:mysql $basedir 
#    ln -s $basedir/my.cnf ~/.my.cnf 
    mysql_install_db --defaults-file=$basedir/my.cnf >/dev/null  2>&1 
    nohup mysqld_safe --defaults-file=$basedir/my.cnf  &
    sleep 2
    ps -ef | grep $port | grep -v grep 
    if [ $? -eq 0 ];then
        res="success"
    else
        res="failed"
    fi
    echo 
    echo "--------------start $res at port $port -----------"
    echo 
}

function mysql_muti_stop_clean(){
    
    if [ $# -ge 1 ];then
        port=$1
    else
        port=3306
    fi 
    ps -ef | grep $port |grep -v grep 
    if [ $? -eq 0 ];then
        mysqladmin --defaults-file=/percona/${port}/my.cnf shutdown
        print_info $? "mysql_shutdown_selfdefine_config"
    fi

    if [ -n $2  ];then 
        rm -rf /percona/$port 
    fi 
}


function percona56_vs_mysql56ce(){
    #TODO 
    percona_tokudb 

}

function percona_tokudb(){
#TODO
echo 
}

function percona56_diagnostic_features(){
    #TODO 
    echo 
}

