#!/bin/bash

#=================================================================
#   文件名称：percona57.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月11日
#   描    述：
#
#================================================================*/

function percona57_install(){
    
    yum install -y Percona-Server-server-57 
    if [ $? -ne 0 ];then
        local vv=`mysqld -V`
        echo $vv | grep -i percona &&   yum remove -y Percona* 
        echo $vv | grep -i alisql  &&   yum remove -y AliSQL* 
        echo $vv | grep -i mariadb &&   yum remove -y mariadb* 
        yum remove -y mysql* 
        print_info $? "percona57 remove other sql databases"
        yum install -y Percona-Server-server-57 
    fi
    if [ $? -eq 0 ];then
        print_info 0 "percona-server-57 install"
    else
        print_info 1 "centos Percona-Server-57 install fail"
        exit 1
    fi

    export LANG="en_US.UTF-8"
    local version1=`yum info Percona-Server-server-57 | grep  Version | cut -d : -f 2 | tr -d "[:blank:]"`
    local repo=`yum info Percona-Server-server-57 | grep "From repo" | cut -d : -f 2 `
    if [ $version1 = "5.7.17" -a $repo = "Estuary" ];then
        true
    else
        false
    fi
    print_info $? "percona57 version"
    export version="percona-$version1-$repo"

}

function percona57_start(){

    export passwd="123"
    
    systemctl stop mysqld.service
    # 安装的时候，会给我们初始化好默认的数据库，使用systemctl直接启动服务即可
#    rm -rf /var/lib/mysql/*

    grep "validate_password" /etc/percona-server.conf.d/mysqld.cnf 
    if [ $? -eq 0 ];then
        sed -i /".*validate_password.*"/d /etc/percona-server.conf.d/mysqld.cnf 
    fi
    mysqld --user=mysql --skip-grant-tables &
    sleep 3
    ps -ef | grep mysqld | grep -v grep 
    if [ $? -eq 0 ];then
        mysql -e "update mysql.user set authentication_string=password($passwd) where user='root' and host='localhost' "
        print_info $? "percona57 change native password"
        mysqladmin shutdown
    else
        echo 
        echo "percona57 skip-grant-tables start error"
        echo
        exit 1
    fi 
    percona57_start_inner 
}

function percona57_password(){

    pswd="Hipassword123;"
    mysql -uroot -p$passwd -e "alter user 'root'@'localhost' identified by 'Hipassword123;'" --connect-expired-password
    print_info $? "percona57 use 'alter user' change root password"
    mysql -uroot -p$pswd -e "set password for 'root'@'localhost' = password('123')"
    if [ $? -eq 0 ];then
        print_info 1 "percona57 password does not satisfy the current policy requirements"
    else
        print_info 0 "percona57 password does not satisfy the current policy requirements"
    fi 
    mysql -uroot -p$pswd -e "show plugins" | grep validate_password | grep -i active
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "percon57 validate_password default active"
    mysql -uroot -p$pswd -e "show variables like '%password%'" | grep validate_password_policy | grep MEDIUM
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "percon57 default password policy is MEDIUM"


    grep "validate_password" /etc/percona-server.conf.d/mysqld.cnf 
    if [ $? -eq 0 ];then
        sed -i s?.*validate_password.*?validate_password=off? /etc/percona-server.conf.d/mysqld.cnf 
    else
        cat >> /etc/percona-server.conf.d/mysqld.cnf <<-eof
[mysqld]
validate_password=off
eof
    fi 
    systemctl restart mysqld.service 
    print_info $? "percon57 turnoff validate_password"

    mysql -uroot -p$pswd -e "set password for 'root'@'localhost' =password('')"
    if [ $? -ne 0 ];then
        echo 
        echo "error has happend"
        echo 
        exit 1
    fi 

}

function percona57_start_inner(){
    

        systemctl start mysqld.service

        if [ $? -eq 0 ];then
            print_info $? "percona57 startd"
        else
            print_info $? "percona57 startd"
            exit 1
        fi
}

function percona57_stop(){
    systemctl stop mysqld.service
    print_info $? "percona57 stop server"
}

function percona57_remove(){

    pid=`ps -ef| grep mysqld | grep -v grep | awk {'print $2'}`
    if [ -n $pid];then 
        kill -9 $pid
    fi
    rm -rf /var/lib/mysql/ 
    print_info $? "percona57 clean up work dir "

    yum remove -y Percona*
    print_info $? "precona57 remove all application"
    
}

function percona57_custom_dir(){

    local port=3306
    if [ $# -ge 1  ];then
        port=$1
    fi
    basedir="/percona57/$port"
    mkdir -p $basedir/{data,log,run}
    cp ./my57.cnf $basedir/my.cnf 
    touch $basedir/log/mysqld.log 
    sed -i s/3306/$port/ $basedir/my.cnf                                                
    sed -i s?"datadir.*"?"datadir=$basedir/data"? ${basedir}/my.cnf
    sed -i s?"socket.*"?"socket=$basedir/data/mysql.sock"? ${basedir}/my.cnf
    sed -i s?"log-error.*"?"log-error=$basedir/log/mysqld.log"? ${basedir}/my.cnf
    sed -i s?"pid-file.*"?"pid-file=$basedir/run/mysqld.pid"? ${basedir}/my.cnf 
    chown -R mysql:mysql $basedir 
#    ln -s -f  $basedir/my.cnf ~/.my.cnf

}

function percona57_custom_init_passwd(){

    
    if [ ! -d ${basedir}/data/sys ];then 
        mysqld --defaults-file=${basedir}/my.cnf --initialize
        print_info $? "percona57 initialize data"
    fi
    
    #  默认是不会安装‘validate_password’插件的
    mysqld --defaults-file=${basedir}/my.cnf --daemonize --skip-grant-tables
    sleep 2
    ps -ef | grep mysqld | grep -v grep 
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "percona57 start server by command and skip-grant-table"
    
    local passwd="123"
    if [ $# -eq 1 ];then
        passwd=$1
    fi

    mysql --defaults-file=${basedir}/my.cnf -uroot -e "update mysql.user set authentication_string=password($passwd) where user='root' and host='localhost'"
    print_info $? "percona57 update root password"
    mysqladmin --defaults-file=${basedir}/my.cnf shutdown
    mysqld --defaults-file=${basedir}/my.cnf --daemonize 
    mysql --defaults-file=${basedir}/my.cnf  -uroot -p$passwd -e "alter user 'root'@'localhost' identified by '123'" --connect-expired-password
    print_info $? "percona57 alter user root password"
}

function percona57_custom_start(){
    local port=$1
    local passwd=$2
    percona57_custom_dir $port
    percona57_custom_init_passwd $passwd
    
}

function percona57_custom_stop(){
    
    ps -ef | grep 'defaults-file' | grep -v grep 
    if [ $? -ne 0 ];then
        echo "All percona had stoped"
        return 0
    fi 

    for file in `ps -ef | grep 'defaults-file=/percona57' | grep -v grep | awk {'print $9'}`
    do 
        mysqladmin $file shutdown -p123
    done 
    ps -ef | grep 'defaults-file' | grep -v grep 
    if [ $? -ne 0 ];then
        true
    else
        false
    fi
    print_info $? "percon57 stop all server"

}

function percona57_master(){

    port=3310
    percona57_custom_start $port 
    repluser='repl'

    ## node 我们这里是一台机器配置主从复制机制，
    mysql --defaults-file=${basedir}/my.cnf -uroot -p123 -e "create user $repluser@'localhost' identified by '123' ; grant replication slave on *.* to $repluser@'localhost'"
    print_info $? "percon57 master create replication account"
    grep log_bin $basedir/my.cnf 
    if [ $? -eq 0 ];then
        sed -i s?.*log_bin.*?log_bin=mysql-bin? $basedir/my.cnf
    else
        cat >> $basedir/my.cnf <<-eof
[mysqld]
log_bin=mysql-bin
eof
    fi
    print_info $? "percona57 master enable log_bin"
    grep server-id $basedir/my.cnf
    if [ $? -eq 0 ];then
        sed -i s?.*server-id.*?server-id=$port? $basedir/my.cnf
    else
        cat >> $basedir/my.cnf <<-eof
[mysqld]
server-id=$port
eof
    fi 
    print_info $? "percona57 master set server-id para"
    mysqladmin --defaults-file=${basedir}/my.cnf shutdown -p123
    mysqld --defaults-file=${basedir}/my.cnf --daemonize 
    mysql --defaults-file=${basedir}/my.cnf -uroot -p123 -e "show master status"
}

function percona57_slave(){
    port=3320
    percona57_custom_start $port
    grep log_bin $basedir/my.cnf 
    if [ $? -eq 0 ];then
        sed -i s?.*log_bin.*?log_bin=mysql-bin? $basedir/my.cnf
    else
        cat >> $basedir/my.cnf <<-eof
[mysqld]
log_bin=mysql-bin
eof
    fi
    print_info $? "percona57 slave enable log_bin "
    grep server-id $basedir/my.cnf
    if [ $? -eq 0 ];then
        sed -i s?.*server-id.*?server-id=$port? $basedir/my.cnf
    else
        cat >> $basedir/my.cnf <<-eof
[mysqld]
server-id=$port
eof
    fi 
    print_info $? "percona57 slave set server-id "
    mysqladmin --defaults-file=${basedir}/my.cnf shutdown -p123

    mysqld --defaults-file=${basedir}/my.cnf --daemonize

    mysql --defaults-file=${basedir}/my.cnf -uroot -p123 -e "change master to master_host='localhost',master_user='repl',master_password='123', \
        master_port=3310,master_log_file='mysql-bin.00001',master_log_pos=154"
    print_info $? "percona57 slave change master to command"
    
    mysql --defaults-file=${basedir}/my.cnf  -uroot -p123 -e "start slave ; stop slave ; reset slave ; start slave" 
    sleep 3
    mysql --defaults-file=${basedir}/my.cnf  -uroot -p123 -e " show slave status\G" | tee slave.status
    
    grep -i  "slave_io_running" slave.status | grep -i yes &&  grep -i "slave_sql_running" slave.status | grep -i yes 
    print_info $? "percona57 replication complication"

}

function percona57_replication(){
    percona57_master
    percona57_slave
    
}
