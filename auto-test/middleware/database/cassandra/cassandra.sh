#!/bin/bash

#=================================================================
#   文件名称：cassandra.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月18日
#   描    述：
#
#================================================================*/

function cassandra20_install(){
    
    yum install -y cassandra20
    print_info $? "install_cassandra20"
    
    export LANG=en_US.UTF8
    yum info cassandra20 | tee tmp.info
    local version=`echo tmp.info | grep -i Version | cut -d : -f 2`
    local repo=`echo tmp.info | grep -i "From repo" | cut -d : -f 2`
    if [ x"$repo" = x"Estuary" ] && [ x"$version" = x"2.0.9" ];then
        true
    else
        false
    fi
    print_info $? "cassandra20_version=$version_and_from_repo=$repo"

    yum install java-1.8.0-openjdk-devel -y 
    javadir=`which java`
    javadirreal=dirname ` readlink -f $javadir`
    
    grep JAVA_HOME ~/.bashrc 
    if [ $? -ne 0 ];then 
        echo "export JAVA_HOME=dirname `dirname $javadirreal`" >> ~/.bashrc 
        echo 'export PATH=$PATH:$JAVA_HOME/bin ' >> ~/.bashrc 
        source ~/.bashrc 
    fi 
    
    yum install -y python2-pip 
    pip install cqlsh==4.1.1 


}

function cassandra20_edit_config(){
    
    sed -i s/'JVM_OPTS="$JVM_OPTS -Xss256k"'/'JVM_OPTS="$JVM_OPTS -Xss328k"'/  /etc/cassandra/default.conf/cassandra-env.sh 
    grep "Xss328k" /etc/cassandra/default.conf/cassandra-env.sh 
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "cassandra20_edit_config_of_JVM_OPTS_per-thread_stack_size"
}


function cassandra20_start_by_service(){

        
    systemctl start cassandra 
    print_info $? "cassandra20_start_by_service"

    jps | grep CassandraDaemon  
    local ret=$?
    if [ $ret -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "lookout_cassandra20_daemon_java_process"


    if test $ret -ne 0;then
        cassandra #直接使用命令去启动

        jps | grep CassandraDaemon | grep -v grep 
        test $? -eq 0 && true || false 
        print_info $? "cassandra20_start_by_command"

        
    fi 


}

function cassandra20_stop_by_service(){
    
    systemctl stop cassandra 
    jps | grep CassandraDaemon 
    local ret=$?
    test $ret -ne 0 && true || false 
    print_info $? "cassandra20_stop_by_service"

    if test $ret -eq 0;then
        kill -9 `jps | grep -i CassandraDaemon | awk {'print $1'}`
        jps | grep CassandraDaemon
        test $? -ne 0 && true || false 
        print_info $? "cassandra20_stop_by_command"
    fi 



}

function cassandra_keyspace_op(){


    cqlsh -e "select keyspace_name from system.schema_keyspaces" | grep tutorialspoint 
    if [ $? -eq 0 ];then
        cqlsh -e "drop KEYSPACE tutorialspoint"
    fi

    cqlsh -e "CREATE KEYSPACE tutorialspoint
    WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 3}"
    cqlsh -e "desc keyspaces" | grep tutorialspoint
    local ret=$?

    print_info $ret "cassandra_create_keyspace"
    if test $ret -ne 0;then
        echo 
        echo "create keyspace error"
        echo 
        exit 1
    fi 

    cqlsh -e "select * from system.schema_keyspaces where keyspace_name = 'tutorialspoint'" | grep True 
    print_info $? "cassandra_keyspace_default_durable_writes_is_true"



    cqlsh -e " ALTER KEYSPACE tutorialspoint
    WITH replication = {'class':'NetworkTopologyStrategy', 'DC1' : 1 , 'DC2' : 3}"
    print_info $? "cassandra_alter_keyspace_replication_strategy"

    cqlsh -e "SELECT * FROM system.schema_keyspaces where keyspace_name = 'tutorialspoint'" | grep NetworkTopologyStrategy 
    print_info $? "cassandra_alter_keyspace_is_effiect"

    cqlsh -e "drop KEYSPACE tutorialspoint"
    print_info $? "cassandra_drop_keyspace"

    cqlsh -e "select keyspace_name from system.schema_keyspaces" | grep tutorialspoint

    test $? -ne 0 && true || false 
    print_info $? "cassandra_drop_keyspace_is_effiect"
 
    cqlsh -e "drop keyspace if exists tutorialspoint"
    print_info $? "cassandra_drop_keyspace"

}

function cassandra_table_op(){
    cqlsh -e "CREATE KEYSPACE tutorialspoint
    WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 3}"

    cqlsh -e "use tutorialspoint ; CREATE TABLE emp(
        emp_id int PRIMARY KEY,
        emp_name text,
        emp_city text,
        emp_sal varint,
        emp_phone varint                 
    )"
    print_info $? "cassandra_create_table"

    cqlsh -e "use tutorialspoint ; ALTER TABLE emp  ADD emp_email text"
    
    cqlsh -e "use tutorialspoint ; select * from emp" | grep emp_email 
    print_info $? "cassandra_alter_add_colume"

    cqlsh -e "use tutorialspoint ; ALTER TABLE emp DROP emp_email"

    cqlsh -e "use tutorialspoint ; select * from emp" | grep emp_email 
    test $? -ne 0 && true || false 
    print_info $? "cassandra_alter_drop_colume"


    cqlsh -e "use tutorialspoint ; CREATE INDEX name ON emp (emp_name)"
    print_info $? "cassandra_add_index"

    cqlsh -e "use tutorialspoint ; drop index name"
    print_info $? "cassandra_drop_index"


    cqlsh -e "use tutorialspoint ; drop table emp"
    print_info $? "cassandra_drop_table"

} 

function cassandra_CURD_op(){

    
    cqlsh -e "use tutorialspoint ; CREATE TABLE emp(
        emp_id int PRIMARY KEY,
        emp_name text,
        emp_city text,
        emp_sal varint,
        emp_phone varint                 
    )"

    cqlsh -e "use tutorialspoint ; INSERT INTO emp (emp_id, emp_name, emp_city, emp_phone, emp_sal) VALUES(1,'ram', 'Hyderabad', 9848022338, 50000)"

    cqlsh -e "use tutorialspoint ; select * from emp" | grep "1 rows"
    print_info $? "cassandra_insert_data"

    cqlsh -e "use tutorialspoint ; UPDATE emp SET emp_city='Delhi',emp_sal=5555 WHERE emp_id=1" 
    cqlsh -e "select * from tutorialspoint.emp" | grep Delhi | grep 555
    print_info $? "cassandra_update_date"


    cqlsh -e "delete from tutorialspoint.emp where emp_id = 1"
    
    cqlsh -e "select * from tutorialspoint.emp" | grep Delhi 
    test $? -ne 0 && true || false
    print_info $? "cassandra_delete_data"



    
}

function cassandra_collection_op(){


    cqlsh -e "use tutorialspoint ;  CREATE TABLE data(name text PRIMARY KEY, email list<text>)"
    print_info $? "cassandra_create_collection_column"
    
    cqlsh -e "use tutorialspoint ; INSERT INTO data(name, email) VALUES ('ramu',  ['abc@gmail.com','cba@yahoo.com'])"
    print_info $? "cassandra_insert_collection_column_data"

    cqlsh -e " use tutorialspoint ;UPDATE data  SET email = email +['xyz@tutorialspoint.com'] where name = 'ramu'"
    print_info $? "cassandra_update_collection_column_data"




}



function cassandra20_sql_ddl(){
    
    cat > temp.cql <<-eof
create keyspace if not exists db1 \
    with replication = {'class':'SimpleStratagy' , 'replication_factor':1} \
    and durable_writes = false;
eof
    local ret=`cqlsh -f temp.cql 2>&1`
    

}


function cassandra20_uninstall(){
    
    yum remove -y cassandra20 
    print_info $? "unintall_cassandra20"
}


