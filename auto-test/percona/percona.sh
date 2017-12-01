#!/bin/bash

#=================================================================
#   文件名称：percona.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年11月27日
#   描    述：
#
#================================================================*/

function close_firewall_seLinux(){
    
    res=`getenforce`
    if [ $res == "Enforcing" ];then
        setenforce 0
    fi
    res1=`getenforce`
    if [ $res1 == "Permissive"  ];then
        true
    else
        false
    fi
    print_info $? "closed seLinux"

    systemctl stop firewalld.service
    print_info $? "stop firewall"

}


function percona_uninstall(){
    
    yum remove -y AliSQL*
    yum remove -y mariadb*
    yum remove -y mysql*
    yum remove -y Percona*
    print_info $? "percona uninstall"

}

function percona_install(){
    
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

    res=`yum info Percona-Server-server-56`
    version=`echo $res | grep Version |  cut -d : -f2`
    repo=`echo $res | grep "From repo" | cut -d : -f 2`
    if [[ $version == "5.6.35" && $repo == "Estuary"  ]];then
        true
    else
        false
    fi

    print_info $? "percona version is right"

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

function mysql_client(){

    #设置密码
    mysqladmin -u root password 123
    print_info $? "mysqladmin set init root password"

    mysql -uroot -p123 -e "status;"
    print_info $? "mysql root use password login"

    mysqladmin -u root -p123 password ""
    print_info $? "mysql cancle password"

    #创建用户
    mysql -e "create user 'mysql'@'%' identified by '123'"
    print_info $? "mysql create user"
    # 这里是授权所有的ip都可以来连接，给了mysql 所有权限（all） 在所有的数据库所有的表（*.*）
    mysql -e "grant all privileges on *.* to 'mysql'@'%'"
    print_info $? "grant privileges on all ip address"
    
    mysql -e "grant all privileges on *.* to 'mysql'@'localhost'"
    print_info $? "grant all privileges on localhost"

    mysql -umysql -p123 -e "select user()"
    print_info $? "mysql login non root user by socket"

    ip=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d '/'`
    mysql -h $ip -umysql -p123 -e "select user()"
    print_info $? "mysql login non root user by tcp"


}

function mysql_load_data(){
    
    if [ ! -d test_db ];then
        git clone https://github.com/datacharmer/test_db.git 
    fi
    mysql -e "drop database if exists employees"
    
    mysql < ./test_db/employees.sql
    print_info $? "mysql import database"
}

function mysql_create(){
    
    mysql -e "drop database if exists mytest"
    mysql -e "create database  mysql"
    print_info $? "mysql create database"
    
    mysql -e "create database if not exists mytest"
    print_info $? "mysql repeat create database"
    
    res=`mysql -e "show databases like 'mytest'"`
    echo $res | grep "mytest"
    print_info $? "mysql lookout database just create"
    

    mysql -e "create event mytest.myevent  on schedule at current_timestamp on select "ee""
    print_info $? "mysql create event"

    mysql <<- eof
    use mytest;
    delimiter //
    create procedure simpleproc (out param1 int)
        begin
            --select count(*) into param1 from titles;
            select 4433 into param1;
        end//
    delimiter ;
eof
    print_info $? "mysql create procedure"
    res2=`mysql -e "call simpleproc(@a);select @a"`
    echo $res2 | grep 4433
    if [ $? -eq 0  ];then
        true
    else
        false
    fi
    print_info $? "mysql call proceduce"

    mysql -e "create server myservername foreign data wrapper mysql optinos (user 'remote',host '127.0.0.1',database 'test'  )"
    print_info $? "mysql create server"
    res3=`mysql -e "select * from mysql.servers where server_name='myservername'"`
    echo $res3 | grep 1
    if [ $? -eq 0  ];then
        true
    else
        false
    fi
    print_info $? "mysql location of create server in the system table"

    # 创建表
    mysql -e "use mytest;create table mytable (id int primary key not null auto_increment , name varchar(20) not null ,index iname (name))"
    print_info $? "mysql create base table"

    mysql -e "use mytest ; create table t2 as select * from mysql.servers"
    print_info $? "mysql use 'create table as query_expr'"

    mysql -e "use mytest ; show create table t2"
    print_info $? "mysql verification 'create table as query_expr'"

    mysql -e "use mytest ; create table t3 likeke t2"
    print_info $? "mysql use 'create table like'"

    #创建分区表
    mysql <<-eof
    system echo "">log
    tee log
    use mytest;
    create table t4 ( col1 INT , col2 CHAR(5))
        partition by hash(col1);
    create table t5 (col1 int , col2 char(5) , col3 datatime)
        partition by hash(year(col3));
    notee
eof
    grep -i  "error" log
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql create partirion table use hash"

    mysql -e "
    use mytest;
    create table t6 (col1 int ,col2 char(5) , col3 date)
        partition by key (col3)
        partitions 4;
    "
    print_info $? "mysql create partition table use key"
    
    mysql -e "use mytest ; create table t6 (col int , col2 char(5) , col3 date)
        partition by linear key(col3)
        partitions 5;"
    print_info $? "mysql create partition table use linear key"

    mysql -e "use mytest ; create table t7(year_col int , some_data int)
        partition by range(year_col) (
            partition p0 values less than (1990),
            partition p1 values less than (1995),
            partition p2 values less than (1999),
            partition p3 values less than (2003),
            partition p4 values less than (2006),
            partition p5 values less than maxvalue,
    );"
    print_info $? "mysql create partition table use range"

    mysql -e "create table t8 (id int , name varchar(35))
    partition by list(id)(
        partition r0 values in (1,5,9,13,17,21),
        partition r1 values in (2,6,10,14,18,22),
        partition r2 values in (3,7,11,15,19,23),
        partition r3 values in (4,8,12,16,20,24),
    );"
    print_info $? "mysql create table use list"

    #触发器
    mysql -e "use mytest ; create trigger insertTrigger before insert on t8 for each row set @a = @a + new.id"
    print_info $? "mysql create trigger"

    mysql -e "use mytest ; create or replace view myview (today) as select current_date "
    print_info  $? "mysql create view"

    
}

function mysql_alter(){

    mysql -e "alter database mytest character set = UTF8 collate = UTF8 "
    if [ $? -eq 0 ];then
        res=`mysql -e "show create database mytest"`
        echo $res | grep -i UTF8 
        if [ $? -eq 0 ];then
            true
        else
            false
        fi
        print_info $? "mysql alter database"
    else
        print_info  1 "mysql alter database"
    fi

    mysql -e "alter event myevent disable"
    print_info $? "mysql alter diabale"

    res2=`mysql -e "use mytest ;show events"`
    echo $res2 | grep -i disable 
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql look event status"

    # 5.7.11
    mysql -e "alter instance rotate innodb master key"
    print_info $? "mysql alter instance"


    mysql -e "alter server myservername options (user 'newremote')"
    if [ $? -eq 0  ];then
        res3=`mysql -e "select * from mysql.servers"`
        echo $res3 | grep newremote
        if [ $? -eq 0 ];then
            true
        else
            false
        fi
        print_info $? "mysql alter server"
    else
        print_info 1 "mysql alter server"
    fi

   #alter table

    mysql <<-efo
    system echo "">log 
    tee log
    drop database if exists alterdb;
    create dabase alterdb;
    use alterdb;
    create table a1 (col1 int , col2 int , col3 int ,col4 int);
    create table a2 (col1 int , col2 int , col3 int ,col4 int);
    notee
efo
    mysql -e "use alterdb ; alter table a1 add col5 int "
    print_info $? "mysql exec alter table add column"

    res4=`mysql -e "desc alterdb.a1"`
    echo $res4 | grep col5
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql alter table add column effictive"

    mysql -e "use alterdb ;alter table a1 add primary key col1"
    print_info $? "mysql exec alter table add primary key"
    res5=`mysql -e 'desc alterdb.a1'>log`
    cat log | grep col1 | grep -i "primary key"
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql alter table add primary key effiection"

    mysql -e "use alterdb ; alter table a1 character set = UTF8 collate UTF8"
    print_info $? "mysql alter table character"
    res6=`mysql -e "show create table alterdb.a1"`
    echo $res6 | grep -i "default charset=utf8"
    print_info $? "mysql alter table character effiection"

    mysql -e "alter table alterdb.a1 change col1 col1_new"
    print_info $? "mysql exec alter table change column name"
    mysql -e "desc alterdb.a1" | grep col1_new
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql alter table column name effiection"

    mysql -e "alter table alterdb.a1 drop col5"
    print_info $? "mysql exec alter table drop column"
    mysql -e "desc alterdb.a1" | grep col5
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql alter table drop column effiection"

    mysql -e "alter table alterdb.a1 drop primary key"
    print_info $? "mysql exec alter table drop primary key"
    mysql -e "show create table alterdb.a1" | grep -i "primary key"
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql alter table drop primary key effiection"

    mysql -e "alter table alterdb.a1 modify col2 date"
    mysql -e "desc alterdb.a1 | grep -i date"
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql alter table modifu column definition"

    mysql -e "alter table alterdb.a1 rename to a1_new"
    mysql -e "use alterdb; show tables" | grep a1_new
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql alter table name"

    mysql -e "alter table alterdb.a1  partition by key(col1) partitions 4"
    mysql -e "show create table alterdb.a1" | grep partitions 
    print_info $? "mysql alter table edit partition"

    mysql <<-eof
    drop table if exists alterdb.t3;
    create table alterdb.t3 (
        id int ,
        year_col int
    )
    partition by range(year_col)(
        partition p0 values less then (1991),
        partition p1 values less then (1995),
        partition p2 values less then (1999)
    );

eof

    mysql -e "alter table alterdb.t3 add partition 
        (partition p4_new values less then (2003))"
    mysql -e "show create table alterdb.t3" | grep p4_new
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql alter add parition count"
    
    mysql -e "alter table alterdb.t3 drop p4_new "
    mysql -e "show create table alterdb.t3" | grep p4_new
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql alter table drop partition"


    mysql -e "alter view  mytest.myview as select upper('mysql')"
    res7=`mysql -e "select * from mytest.myevent"`
    echo $res7 | grep MYSQL 
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info  $? "mysql alter view"

}

function mysql_drop(){
    
    #drop view
    mysql -e "drop view mytest.myview" 
    mysql -e "select * from information_schema.views" | grep myview
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql drop view"

    #drop trigger
    mysql -e "drop trigger mytest.insertTrigger"
    mysql -e "select * from information_schema.triggers" | grep insertTrigger
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql drop trigger"
    
    #drop server
    mysql -e "drop server myservername"
    mysql -e "select * from mysql.servers" | grep myservername 
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql drop server"

    # drop procedure 
    mysql -e "drop procedure mytest.simpleproc"
    mysql -e "select * from mysql.proc" | grep simpleproc
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql drop procedure"

    # drop index 
    mysql -e "drop index iname on mytest.mytable"
    # myteble exist primary key 
    res=`mysql -e "show create table mytest.mytable" | grep -c -i key`
    if [ $res == 1 ];then
        true
    else
        false
    fi
    print_info $? "mysql drop index"

    mysql -e 'drop index `PRIMARY` on mytest.mytable'
    mysql -e "show create table mytest.mytable" | grep -i PRIMARY 
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql drop primary key"
    
    #drop event 
    mysql -e "drop event mytest.myevent"
    mysql -e "select name from mysql.event" | grep myevent 
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql drop event"

    # drop table
    mysql -e "drop table mytest.mytable"
    mysql -e "use mytest ; show tables" | grep mytable
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql drop table"

    #drop databases
    mysql -e "drop database mytest"
    mysql -e "show databaases" | grep mytest
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql drop database"

}

function mysql_select(){

# signle table query 
    # 1 base
    res1=`mysql -e "select 1+1 from dual"`
    echo $res1 | grep 2
    [ $? -eq 0 ] && true
    print_info $? "mysql select rows computer without table"

    mysql -e "select current_date()"
    print_info $? "mysql select function"

    mysql -e "select count(*) from employees.employees"
    print_info $? "mysql select from clause"

    # 2 where 
    mysql -e "select count(*) from employees.employees where year(hire_date)-year(birth_date)=20"
    print_info $? "mysql select where clause"
    # 3 group by
    mysql -e "select gender ,count(*) from employees.employees group by gender"
    print_info $? "mysql select group by clause"

    # 4 having 
    mysql -e "select * from employees.employees where year(hire_date)-year(birth_date) having year(hire_date)=2000"
    print_info $? "mysql select having clause"

    # 5 order by
    mysql -e "select * from employees.employees  "
    # 6 limit 

    # 7 into outfile


    
}

function mysql_insert(){
echo

}
