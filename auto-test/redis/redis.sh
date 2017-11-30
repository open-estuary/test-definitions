#!/bin/bash
#================================================================
#   Copyright (C) 2017. All rights reserved.
#   
#   文件名称：redis.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年11月22日
#   描    述：
#
#================================================================


function install_redis(){
    
    yum install -y redis 
    print_info $? "install redis"

    version=`redis-server --version | awk {'print $3'}`
    if [ $version == "v=4.0.2" ];then
        true
    else
        false
    fi
    print_info $? "redis version is 4.0.2 ?"


    #修改配置文件，可以后台运行
    sed -i 's/daemonize no/daemonize yes/' /etc/redis.conf 
    grep "daemonize yes" /etc/redis.conf 
    print_info $? "redis edit config file ,that can run background"
    
}
function redis_uninstall(){
    
    ps -ef | grep redis_server | grep -v grep
    if [ $? -eq 0 ];then
        redis_stop -a
    fi
    yum -y remove redis 
    print_info $? "redis uninstall"
    rm -rf /redis/db/ 
    print_info $? "redis clean up workdir"
}
function redis_start(){
   
    port=$1
    
    if [ -z $port  ];then
        port="6379"
    fi
    
    ps -ef | grep "redis-server.*${port}" | grep -v grep
    if [ $? -eq 0 ];then 
        lava-test-case "redis server is running"
        return 1
    fi 
    
    mkdir -p /redis/db/$port

    unalias cp 
    cp -f /etc/redis.conf /redis/db/$port 
    
    #修改配置文件，可以后台运行
    sed -i 's/daemonize no/daemonize yes/' /redis/db/${port}/redis.conf 
    grep "daemonize yes" /redis/db/${port}/redis.conf  
    print_info $? "redis edit config file ,that can run background"

    # 修改数据存放位置
    sed -i "s/^dir.*/dir \/redis\/db\/${port}/" /redis/db/${port}/redis.conf 

    file="/redis/db/${port}/redis.conf"

    ps -ef | grep  "redis-server.*$port" | grep -v grep 
    if [ $? -eq 0  ];then
        lava-test-case "redis server is running"
    else
        redis-server $file --port $port
        print_info $? "redis started"
    fi

}


function redis_stop(){
   port=""
   stopALl=false
    while getopts "ap:" arg
    do
        case $arg in 
        a)
            stopALl=true
            ;;
        p)
            port=$OPTARG
            ;;
        ?)
            echo "error argument"
            ;;
        esac
    done
    if [ $stopALl  ];then
        ports=`ps -ef | grep "redis-server" | grep -v grep | awk {'print $NF'} | cut -d : -f 2`
        for port in $ports
        do 
            redis-cli -p $port shutdown
        done 
        count=`ps -ef | grep "redis-server" | grep -v -c grep`
        if [ $count -eq 0 ];then
            true
        else
            false
        fi
        print_info $? "redis shutdownt all server"
        return 0
    fi


    if [ -z $port  ];then
        port="6379"
    fi 
    ps -ef | grep "redis-server.*$port" | grep -v grep
    if [ $? -eq 0  ];then
        redis-cli -p $port shutdown 
        print_info $? "redis server shutdown"
    fi


}

function redis_auth(){
    
    res=`redis-cli CONFIG set requirepass 123`
    if [ $res == "OK"  ];then
        true
    else
        false
    fi
    print_info $? "redis set password"
    
    res1=`redis-cli -a 123 CONFIG get requirepass`
    echo $res1 | grep "error"
    if [ $? -eq 0 ];then
        false 
    else
        true 
    fi
    print_info $? "redis login use password"
    
    
    res3=`redis-cli -a 123 CONFIG set requirepass ""`
    if [ $res == "OK"  ];then
        true
    else
        false
    fi
    print_info $? "redis cancle password"
    
    
}


function redis_string_test(){
    
    res=`redis-cli ping`
    if [ $res == "PONG"  ];then
        true
    else
        false
    fi
    print_info $? "redis ping command "
    
    res0=`redis-cli flushall`
    if [ $res0 == "OK" ];then
        true
    else
        false
    fi
    print_info $? "redis flushall command"

    res1=`redis-cli set redis redis`
    if [ $res1 == "OK"  ];then
        true
    else
        false
    fi
    print_info $? "redis set command"

    res2=`redis-cli get redis`
    if [ $res2=="redis" ] ;then
        true
    else
        false
    fi
    print_info $? "redis get command"

    res3=`redis-cli getrange redis 1 2`
    if [ $res3 == "ed" ];then
        true
    else
        false
    fi
    print_info $? "redis getrange command"
    
    res6=`redis-cli get redis`
    res4=`redis-cli getset redis database`
    res5=`redis-cli get redis`
    if [[ $res4 == $res6 && $res5 = "database"  ]];then
        true
    else
        false
    fi
    print_info $? "redis getset command"

    redis-cli set estuary root
    res7=`redis-cli mget estuary redis`
    echo $res7 | grep database && echo $res7 | grep root
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "redis mget command"

    
    res8=`redis-cli setnx redis redis`
    res9=`redis-cli setnx book book`
    if [[  $res8 == 0 && $res9 == 1  ]];then
        true
    else
        false
    fi
    print_info $? "redis setnx command"

    redis-cli set num 10
    redis-cli incr num
    res10=`redis-cli get num`
    if [ $res10 == 11  ];then
        true
    else
        false
    fi
    print_info $? "redis incr command"

    res11=`redis-cli decr num`
    if [ $res11 == 10 ];then
        true
    else
        false
    fi
    print_info $? "redis decrr command"

    redis-cli set redis aa
    res12=`redis-cli strlen redis`
    if [ $res12 == 2  ];then
        true
    else
        false
    fi
    print_info $? "redis strlen command"



}

function redis_hash_test(){
    
    res1=`redis-cli HMSET myhash field1 "hello" field2 "world"`
    if [ $res1 == "OK" ];then
        true
    else
        false
    fi
    print_info $? "redis hmset command"

    res2=`redis-cli HGET myhash field1`
    if [ $res2 == "hello" ];then
        true
    else
        false
    fi
    print_info $? "redis hget command"

    res3=`redis-cli hexists myhash field2`
    if [ $res3 == 1 ];then
        true
    else
        false
    fi
    print_info $? "redis hexists command"

    res4=`redis-cli hkeys myhash`
    echo $res4 | grep "field1"  && echo $res4 | grep "field2"
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "redis HKEYS command"


    res5=`redis-cli hvals myhash`
    echo $res5 | grep "hello" && echo $res5 | grep "world"
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "redis HVALS command"

}

function redis_list_test(){

    res1=`redis-cli LPUSH rediskey redis`
    if [ $res1 -ge 1 ];then
        true
    else
        false
    fi
    print_info $? "redis HPUSH command"
    
    redis-cli LPUSH rediskey mongodb
    res2=`redis-cli LRANGE rediskey 0 -1`
    echo $res2 | grep "mongodb redis"
    if [ $?  -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "redis LRANGE command"

    redis-cli RPUSH rediskey mysql
    res3=`redis-cli LINDEX rediskey -1`
    if [ $res3 == "mysql" ];then
        true
    else
        false
    fi
    print_info $? "redis RPUSH command"

    redis-cli RPUSHX rediskey postgresql
    res4=`redis-cli RPUSHX rediskeyx postgresql`
    res5=`redis-cli LINDEX rediskey -1`
    if [[  $res4 == 0 &&  $res5 == "postgresql" ]];then
        true
    else
        false
    fi
    print_info $? "redis RPUSHX command"

    res6=`redis-cli LLEN rediskey`
    if [ $res6 == 4 ];then
        true
    else
        false
    fi
    print_info $? "redis LLEN command"

    res7=`redis-cli LPOP rediskey`
    if [ $res7 == "mongodb" ];then
        true
    else
        false
    fi
    print_info $? "redis LPOP command"

    res8=`redis-cli RPOP rediskey`
    if [ $res8 == "postgresql" ];then
        true
    else
        false
    fi
    print_info $? "redis RPOP command"

}

function redis_set_test(){

    res1=`redis-cli SADD redisset redis`
    if [ $res1 -ge 1  ];then
        true
    else
        false
    fi
    print_info $? "redis SADD command"


    res2=`redis-cli SISMEMBER redisset redis`
    if [ $res2 -eq 1  ];then
        true
    else
        false
    fi
    print_info $? "redis SISMEMBER command"
    redis-cli SADD redisset mysql
    redis-cli SADD redisset mongodb 
    redis-cli SADD redisset2 redis mysql postgresql 

    res3=`redis-cli SCARD redisset`
    res4=`redis-cli SCARD redisset3`
    if [[ $res3 == 3 && $res4 == 0   ]];then
        true
    else
        false
    fi
    print_info $? "redis SCARD commad"

    res5=`redis-cli SDIFF redisset redisset2`
    if [ $res5 == "mongodb" ];then
        true
    else
        false
    fi
    print_info $? "redis SDIFF command"

    res6=`redis-cli SINTER redisset redisset2`
    echo $res6 | grep redis && echo $res6 | grep mysql 
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "redis SINTER command"

    res7=`redis-cli SUNION redisset redisset2`
    echo $res7 | grep redis && echo $res7 | grep postgresql
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "redis SUNION command"

    res8=`redis-cli SREM redisset redis`
    if [ $res8 -eq 1 ];then
        true
    else
        false
    fi
    print_info $? "redis SREM command"

}

function redis_sortedset_test(){
    
   res=`redis-cli ZADD sortkey 1  "one"`
   if [ $res -eq 1 ];then
       true
   else
       false
   fi
   print_info $? "redis ZADD commad"



}

function redis_save_test(){

    res=`redis-cli set save isSave`
    res2=`redis-cli save`
    if [ $res2 == "OK"  ];then
        true
    else
        false
    fi
    print_info $? "redis sava database"

    res3=`redis-cli CONFIG GET dir`
    path=`echo $res3 | cut -d " " -f 2`

   
    mkdir -p /redis/db/7777 

    cp ${path}/dump.rdb /redis/db/7777/
    redis_start  7777


    res4=`redis-cli -p 7777 GET save`
    if [ $res4 == "isSave"  ];then
        true
    else
        false
    fi
    print_info $? "redis restore database"

}

function redis_transaction_test(){

    cat > tmp.txt <<-eof
    MULTI
    FLUSHALL 
    SET bookname "c++" 
    GET bookname
    SADD tag "c++" "mastering series" "programming"
    SISMEMBER tag "c++"
    EXEC

eof
    
    res1=`cat tmp.txt | redis-cli`
    echo $res1 | grep "OK OK c++ 3 1"
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "redis transaction exec  command"


    cat > tmp.txt <<-eof
    MULTI
    FLUSHALL 
    SET bookname "c++" 
    GET bookname
    SADD tag "c++" "mastering series" "programming"
    SISMEMBER tag "c++"
    DISCARD
eof
    res2=`cat tmp.txt | redis-cli`
    echo $res2 | grep "^OK.*OK$"
    if [ $? -eq 0 ];then
        true
    else
        false
    fi
    print_info $? "redis transaction  discard command"

}



