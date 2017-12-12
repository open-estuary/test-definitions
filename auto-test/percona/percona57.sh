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
        vv=`mysqld -V`
        echo $vv | grep -i percona &&   yum remove -y Percona* 
        echo $vv | grep -i alisql  &&   yum remove -y AliSQL* 
        echo $vv | grep -i mariadb &&   yum remove -y mariadb* 
        yum remove -y mysql* 
        print_info $? "percona57 remove other sql databases"
        yum install -y Percona-Server-57 
    fi
    if [ $? -eq 0 ];then
        print_info 0 "percona-server-57 install"
    else
        print_info 1 "centos Percona-Server-57 install fail"
        exit 1
    fi

    export LANG="en_US.UTF-8"
    versioin1=`yum info Percona-Server-server-57 | grep  Version | cut -d : -f 2`
    repo=`yum info Percona-Server-server-57 | grep "From repo" | cut -d : -f 2`
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

    systemctl restart mysqld.service 
    mysql -uroot -p123 -e "show status" > /dev/null 2>&1
    if [ $? -eq 0 ];then
        echo "percoan57 had set native password"
        print_info $? "percona57 had startd"    
        return 0
    fi 

    systemctl stop mysqld.service 
    mysqld --user=mysql --skip-grant-tables &
    sleep 1
    ps -ef | grep mysqld | grep -v grep 
    if [ $? -eq 0 ];then
        mysql -e "update mysql.user set authentication_string=password($passwd) where user='root' and host='localhost' "
        print_info $? "percona57 change native password"
        mysqladmin shutdown
    fi 
    percona57_start_inner 

}

function percona57_password(){

    pswd="Hipassword123;"
    mysql -uroot -p$passwd -e "alter user 'root'@'localhost' identified by $pswd"
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

    mysql -uroot -p$pswd -e "set password for 'root'@'localhost' password($passwd)"

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
