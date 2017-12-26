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
    print_info $? "install cassandra20"
    
    export LANG=en_US.UTF8
    yum info cassandra20 | tee tmp.info
    local version=`grep -i Version | cut -d : -f 2`
    local repo=`grep -i "From repo" | cut -d : -f 2`
    if [ $repo = "Estuary" ] && [ $version = "2.0.9" ];then
        true
    else
        false
    fi
    print_info $? "cassandra20 version=$version and from_repo=$repo"

    yum install java-1.8.0-openjdk-devel -y 
    javadir=`which java`
    javadirreal=dirname ` readlink -f $javadir`
    
    grep JAVA_HOME ~/.bashrc 
    if [ $? -ne 0 ];then 
        echo "export JAVA_HOME=dirname `dirname $javadirreal`" >> ~/.bashrc 
        echo 'export PATH=$PATH:$JAVA_HOME/bin ' >> ~/.bashrc 
        source ~/.bashrc 
    fi 
    
    yum install -y python-pip 
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
    print_info $? "cassandra20 edit config of JVM_OPTS per-thread stack size"
}


function cassandra20_start_by_service(){

        
    systemctl start cassandra 
    print_info $? "cassandra20 start"

    jps | grep CassandraDaemon 
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "lookout cassandra20 daemon java process"

}

function cassandra20_stop_by_service(){
    
    systemctl stop cassandra 
    jps | grep CassandraDaemon 
    if [ $? -ne 0 ];then
        true
    else
        false
    fi
    print_info $? "cassandra20 stop by service"

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
    print_info $? "unintall cassandra20"
}



function cassandra20_sql_dml(){
echo
#TODO
}

function cassandra20_sql_index(){
    #TODO
echo
}


function cassandra20_sql_role_perm(){
    #TODO
echo
}

function cassandra20_sql_udf(){
    #TODO
echo
}


function cassandra20_sql_udt(){
    #TODO
echo
}


function cassandra20_sql_trigger(){
    #TODO
echo
}
