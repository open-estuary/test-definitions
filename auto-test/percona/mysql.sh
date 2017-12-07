#!/bin/bash

#=================================================================
#   文件名称：mysql.sh
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
   
    mysql -e "create user 'mysql'@'localhost' identified by '123'"
    mysql -e "grant all privileges on *.* to 'mysql'@'localhost'"
    print_info $? "grant all privileges on localhost"

    mysql -umysql -p123 -e "select user()"
    print_info $? "mysql login non root user by socket"

    ip=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d '/'`
    mysql -h $ip -umysql -p123 -e "select user()"
    print_info $? "mysql login non root user by tcp"
    
    mysql -e "drop user 'mysql'@'%'"
    print_info $? "mysql drop user@%"
    mysql -e "drop user 'mysql'@'localhost'"
    print_info $? "mysql drop user@localhost "

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
    mysql -e "create database  mytest"
    print_info $? "mysql create database"
    
    mysql -e "create database if not exists mytest"
    print_info $? "mysql repeat create database"
    
    res=`mysql -e "show databases like 'mytest'"`
    echo $res | grep "mytest"
    print_info $? "mysql lookout database just create"
    

    mysql -e "create event mytest.myevent  on schedule at current_timestamp do select 'ee'"
    print_info $? "mysql create event"

    mysql <<- eof
    use mytest;
    delimiter //
    create procedure simpleproc (out param1 int)
        begin
            select 4433 into param1;
        end//
    delimiter ;
eof
    print_info $? "mysql create procedure"
    res2=`mysql -e "use mytest ; call simpleproc(@a);select @a"`
    echo $res2 | grep 4433
    if [ $? -eq 0  ];then
        true
    else
        false
    fi
    print_info $? "mysql call proceduce"

    mysql -e "create server myservername foreign data wrapper mysql options (user 'remote',host '127.0.0.1',database 'test'  )"
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
    mysql -e "use mytest;create table mytable (id int primary key not null  , name varchar(20) not null ,index iname (name))"
    print_info $? "mysql create base table"

    mysql -e "use mytest ; create table t2 as select * from mysql.servers"
    print_info $? "mysql use 'create table as query_expr'"

    mysql -e "use mytest ; show create table t2"
    print_info $? "mysql verification 'create table as query_expr'"

    mysql -e "use mytest ; create table t3 like t2"
    print_info $? "mysql use 'create table like'"

    #创建分区表
    mysql <<-eof
    system echo "">log
    tee log
    use mytest;
    create table t4 ( col1 INT , col2 CHAR(5))
        partition by hash(col1);
    create table t5 (col1 int , col2 char(5) , col3 datetime)
        partition by hash(year(col3));
    notee
eof
    cat log 
    grep -i  "error" log
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql create partirion table use hash"

    mysql -e "
    use mytest;
    create table t6 (col1 int ,col2 char(5) , col3 date)
        partition by key (col3)
        partitions 4;
    "
    print_info $? "mysql create partition table use key"
    
    mysql -e "use mytest ; create table t9 (col int , col2 char(5) , col3 date)
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
            partition p5 values less than maxvalue
    );"
    print_info $? "use mytest ;mysql create partition table use range"

    mysql -e "use mytest ; create table t8 (id int , name varchar(35))
    partition by list(id)(
        partition r0 values in (1,5,9,13,17,21),
        partition r1 values in (2,6,10,14,18,22),
        partition r2 values in (3,7,11,15,19,23),
        partition r3 values in (4,8,12,16,20,24)
    );"
    print_info $? "mysql create table use list"

    #触发器
    mysql -e "use mytest ; create trigger insertTrigger before insert on t8 for each row set @a = @a + new.id"
    print_info $? "mysql create trigger"

    mysql -e "use mytest ; create or replace view myview (today) as select current_date "
    print_info  $? "mysql create view"

    
}

function mysql_alter(){

    mysql -e "alter database mytest character set = utf8 collate = utf8_general_ci "
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

    mysql -e "alter event mytest.myevent disable"
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
    print_info $? "mysql alter instance only in 5.7.11 effictive"


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
    create database alterdb;
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

    mysql -e "use alterdb ;alter table a1 add primary key (col1)"
    print_info $? "mysql exec alter table add primary key"
    mysql -e 'show create table alterdb.a1'>log
    cat log | grep col1 | grep -i "primary key"
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql alter table add primary key effiection"

    mysql -e "use alterdb ; alter table a1 character set = utf8 collate utf8_general_ci"
    print_info $? "mysql alter table character"
    res6=`mysql -e "show create table alterdb.a1"`
    echo $res6 | grep -i "default charset=utf8"
    print_info $? "mysql alter table character effiection"

    mysql -e "alter table alterdb.a1 change col1 col1_new int"
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
    mysql -e "desc alterdb.a1 "| grep -i date
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql alter table modify column definition"

    mysql -e "alter table alterdb.a1 rename to alterdb.a1_new"
    mysql -e "use alterdb; show tables" | grep a1_new
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql alter table name"

    mysql -e "alter table alterdb.a1_new  partition by key (col2) partitions 4"
    mysql -e "show create table alterdb.a1_new" | grep -i partitions 
    print_info $? "mysql alter table edit partition"

    mysql <<-eof
    drop table if exists alterdb.t3;
    create table alterdb.t3 (
        id int ,
        year_col int
    )
    partition by range(year_col)(
        partition p0 values less than (1991),
        partition p1 values less than (1995),
        partition p2 values less than (1999)
    );

eof

    mysql -e "alter table alterdb.t3 add partition 
        (partition p4_new values less than (2003))"
    mysql -e "use alterdb ; show create table t3" | grep p4_new
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql alter add parition count"
    
    mysql -e "alter table alterdb.t3 drop partition p4_new "
    mysql -e "show create table alterdb.t3" | grep p4_new
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysql alter table drop partition"


    mysql -e "alter view  mytest.myview as select upper('mysqlview')"
    res7=`mysql -e "select * from mytest.myview"`
    echo $res7 | grep MYSQLVIEW 
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

    mysql -e 'use mytest ;drop index `PRIMARY` on mytable'
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
    mysql -e "select * from employees.employees  order by 3 limit 1"
    print_info $? "mysql order by clause"
    # 6 limit 
    mysql -e "select * from employees.employees limit 3"
    print_info $? "mysql limit clause"

    # 7 into outfile
    intopath=`mysql -e "show variables like '%secure_file_priv%'\G" | grep -i value | cut -d : -f 2`
    echo $intopath | grep -i null
    if [ $? -ne 0 ];then
        pushd .
        cd $intopath
        rm -f tmp.dump 
        mysql -e "select * from employees.employees limit 10 into outfile 'tmp.dump'"
        print_info $? "mysql into outfile clause"
        popd 
    fi
   

    # 多表查询问题
    mysql -e "use employees ;select * from employees as e inner join dept_emp as d on e.emp_no=d.emp_no limit 3"
    print_info $? "mysql inner join test"
    
    mysql -e "use employees ; select * from employees e left join dept_emp d on e.emp_no=d.emp_no limit 3"
    print_info $? "mysql left join"

    mysql -e "use employees ; select * from employees e right join dept_emp d on e.emp_no=d.emp_no limit 3 "
    print_info $? "mysql right join"

    #子查询问题
    echo "mysql subquery as scalar operand"
    mysql -e "use employees ; select upper((select dept_name from departments where dept_no='d001')) as dept from dual"
    print_info $? "mysql subquery as saclar operand"

    echo "mysql subquery use comparisions"
    mysql -e "use employees ; select * from salaries as s where emp_no = (select emp_no from employees where last_name ='peac' and first_name ='yifei');"
    print_info $? "mysql subquery comparisons"
    
    echo "mysql subquery with in"
    mysql -e "use employees ; select * from employees where emp_no in (select emp_no from dept_manager)"
    print_info $? "mysql subquery in"

    echo "mysql subquery with not in"
    mysql -e "use employees ; select count(*) from employees where emp_no not in (select emp_no from dept_manager)"
    print_info $? "mysql with not in"

    echo "mysql subquery with any"
    mysql -e "use employees ; select count(*) from employees where emp_no = any (select emp_no from dept_manager)"
    print_info $? "mysql with any"

    
    echo "mysql subquery with  all"
    mysql -e "use employees ;  select count(*) from salaries s where s.salary > all (select s.salary from dept_manager d join salaries s on d.emp_no = s.emp_no where year(s.to_date)>year(current_date));"
    print_info $? "mysql with not in"
    

    echo "mysql subquery in the from clause"
    mysql -e "use employees ; select * from (select * from dept_manager) as new_table"
    print_info $? "mysql subquery in from clause"

    
    echo "mysql update"
    mysql -e "use employees ; update dept_manager set dept_no = 'd007' where emp_no = '111939'"
    print_info $? "mysql update row information"
    
}

function mysql_insert(){
    
    mysql < "drop database if exists test;
            create database test ;
            create table t1 (id int , name varchar(20) , age int);
            create table t2 (id int , name varchar(20))"
    mysql -e '''use test ; insert into t1 values(1 , "tan" , 20)'''
    print_info $? "mysql insert into all colume values"

    mysql -e '''use test ; insert into t1 (id,name) values(2,"lee")'''
    print_info $? "mysql insert into special column value"

    mysql -e '''use test; insert into t1 set id=2 , name="tom" , age=20'''
    print_info $? "mysql insert into set "
    
    mysql -e "use test ; insert into t2 select t1.id , t1.name from t1 where t1.age =20"
    print_info $? "mysql insert select"

}

function mysql_delete(){
    mysql -e "use test ; delete from t1 where id=2"
    print_info $? "mysql delete where clause"

    mysql -e "use test ; delete from t1 where ag2 = 20 limit 1"
    print_info $? "mysql delete where limit clause"
}

function mysql_transaction(){
    res=`mysql -e "show variables like '%autocommit%'"`
    echo $res | grep "ON"
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql get default commit mode"

    mysql -e "set autocommit=off"
    print_info $? "mysql close autocommit"
    mysql -e "set autocommit=on"

    res1=`mysql -e "select @@tx_isolation"`
    echo $res1 | grep -i "repeatble-read"
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql default isolation level is repreatble_read"

    mysql -e "set session transaction isolation level read uncommitted"
    print_info $? "mysql set isolation level"
    

    mysql -e '''
    drop database if exists test;
    create database test;
    use test;
    create table t1 (id int , name varchar(20));
    insert into t1 values (1,"lee") ,(2,"tom");
    exit
'''
    
    
    # 未提交读
    echo "" > a.log 
    mysql -e '''
        set session transaction isolation level read uncommitted;
        use test;
        tee a.log ;
        select name from t1 where id=1;
        select sleep(1);
        select name from t1 where id=1;
        notee;
        exit
    ''' &
    mysql -e '''
        set session transaction isolation level read uncommitted;
        start transaction;
        use test;
        update t1 set name="newlee" where id=1;
        select sleep(2);
        rollback;
        exit
''' &
    sleep 3
     grep newlee a.log 
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql transaction read uncommitted "

    
    # 读已提交
    echo "" > a.log 
    mysql -e '''
        set session transaction isolation level read committed;
        use test; 
        tee a.log;
        start transaction;
        select name from t1 where id=1;
        select sleep(1);
        select name from t1 where id=1;
        notee;
        exit
    ''' &
    mysql -e '''
        use test;
        set session transaction isolation level read committed;
        start transaction;
        update t1 set name="newlee" where id=1;
        commit;
        exit
    '''
    sleep 1
    grep newlee a.log
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql transaction read committed"

    #可重复读
    echo "" > a.log
    mysql -e '''
        set session transaction isolation level repeatable read;
        use test;
        tee a.log ;
        start transaction;
        select name from t1 where id=1;
        select sleep(1);
        select name from t1 where id=1;
        notee;
        exit
    '''
    mysql -e '''
        use test;
        set session transaction isolation level repeatable read;
        start transaction;
        update t1 set name="lizi" where id=1;
        commit;
        exit
    ''' 
    sleep 1
    grep lizi a.log 
    if [ $? -ne 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql transaction repreatable read"

    #串行化
    echo "" > a.log 
    mysql -e '''
        use test;
        set session transaction isolation level serializable;
        start transaction;
        insert into t1 values (1, "serializable");
        select * from t1;
        select sleep(50);
        commit;
        exit
    ''' &
    pid1=$! 
    mysql -e '''
        use test;
        tee a.log;
        set session transaction isolation level serializable;
        start transaction;
        insert into t1 values (5,"ddd");
        select * from t1;
        commit;
        notee;
        exit
    '''  &
    pid=$!
    while (true)
    do

        ps -ef | grep $pid | grep -v grep  
        if [ $? -eq 0 ];then
            sleep 2
        else
            break
        fi
    done 
    cat a.log 
    kill -9 $pid1

    grep -i error a.log  
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysql transaction serializable"

}

function mysql_variable(){
    
    mysql -e "show variables like '%character%'"
    print_info $? "mysql query all character varible"
    
    mysql -e "select user()"
    print_info $? "mysql query current user"

    mysql -e "select database()"
    print_info $? "mysql query currnet database"

    mysql -e "set names utf8"
    print_info $? "mysql set client,connect result character set"

}

function mysql_system_database(){

    mysql -e "select * from mysql.event"
    print_info $? "mysql query all define event"

    mysql -e "select * from mysql.proc"
    print_info $? "mysql query all define procedure"

    mysql -e "select * from mysql.func"
    print_info $? "mysql query all define function"

    mysql -e "select * from mysql.user"
    print_info $? "mysql query all users"

    mysql -e "select * from information_schema.tables"
    print_info $? "mysql query all tables in the server"

    mysql -e "select * from information_schema.triggers"
    print_info $? "mysql query all define trigger"

    mysql -e "select * from information_schema.views"
    print_info $? "mysql query all define views"

    
}

function mysql_admin(){
    
    mysqlshow 
    print_info $? "mysqlshow command"
    
    mysqladmin  ping
    print_info $? "mysqladmin ping server"
    mysqladmin status
    print_info $? "mysqladmin status"
    mysqladmin create database admindb
    mysqlshow | grep amdindb
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "mysqladmin create database"

    mysql -e "select sleep(40)" &
    mysqladmin processlist
    print_info $? "mysqladmin processlist thread"
    id=`mysqladmin processlist | grep "select sleep" | cut -d "|" -f 2`
    mysqladmin kill $id 
    mysqladmin processlist | grep "select sleep"
    if [ $? -eq 0 ];then
        false
    else
        true
    fi
    print_info $? "mysqladmin kill thread"

    mysql -e "create database if not exists my1"
    mysqlcheck mysql
    print_info $? "msyqlcheck command"


}
