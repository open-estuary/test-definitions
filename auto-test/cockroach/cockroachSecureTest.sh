#! /bin/bash 


basedir=`cd `dirname $0` ;pwd`
cd $basedir 
. ../../lib/sh-test-lib 

install_deps cockroach

if [ `which cockroach`  ] ;then
    lava-test-case "cockroach install " --result pass 
else
    lava-test-case "cockroach install" --result fail 
fi

version=`cockroach version | grep "Build Tag:" | awk '{print $3}'`
if [ $version = "v1.0.3"  ];then
    lava-test-case "cockroach version" --result pass 
else
    lava-test-case "cockroach version" --result fail 
fi

cockroach start --insecure --host=localhsot --background

if [ `ps -ef |grep cockroach | grep -v grep`  ];then
    lava-test-case "cockroach start node1" --result pass 
else
    lava-test-case "cockroach start node1" --result fail 
fi

cockroach start --insecure --store=node2 --host=localhost --port=26258 --http-port=8081 --join=localhost:26257 --background
cockroach start --insecure --store=node3 --host=localhost --port=26259 --http-port=8082 --join=localhost:26257 --background

if [ `ps -ef |grep cockroach | grep -v grep | wc -l` = 3 ] ;then
    lava-test-case "cockroach cluster start" --result pass 
else
    lava-test-case "cockroach cluster start" --result fail
fi
echo 
echo "cockroach insecure cluster start successed"
echo 

nodestatus1=`cockroach node ls --insecure` 
nodestatus2=`cockroach node status --insecure`
if [ $nodestatus1 != "" -a $nodestatus2 != ""  ] ;then
    lava-test-case "cockroach status " --result pass 
else
    lava-test-case "cockroach status" --result fail
fi

cockroach sql --insecure -e "DROP DATABASE IF EXISTS bank;"
res=`cockroach sql --insecure -e "CREATE TABLE bank.accounts (id INT PRIMARY , balance DECIMAL);
                            INSERT INTO bank.accounts VALUES (1 , 1000.50);
                            SELECT * FROM bank.accounts;"`
if [ x$res = x"1 row id balance 1 1000.50" ] ;then
    lava-test-case "cockroach node1 executer sql statement" --result pass 
else
    lava-test-case "cockroach node1 executer sql statement" --result fail 
fi

node2res=`cockroach sql --insecure --port=26256 -e "SELECT * FROM bank.accounts"`

if [ x$node2res = x"1 row id balance 1 1000.50" ] ;then
    lava-test-case "cockroach node2 executer sql statement" --result pass 
else
    lava-test-case "cockroach node2 executer sql statement" --result fail 
fi

ps -ef | grep cockroach | grep node2 | grep -v grep | awk '{print $2}' | xargs kill -9
noderes=`cockroach sql --insecure -e "SELECT * FROM bank.accounts"`

if [ x$noderes = x"1 row id balance 1 1000.50" ] ;then
    lava-test-case "cockroach single point failure" --result pass 
else
    lava-test-case "cockroach single point failure" --result fail 
fi

ps -ef | grep cockroach | grep -v grep | awk '{print $2}'| xargs kill -9
stopCluster=`ps -ef | grep cockroach | grep -v grep`
if [ -z  $stopCluster ];then
    lava-test-case "cockroach stop cluster" --result pass
else
    lava-test-case "cockroach stop cluster" --result fail
fi

remove_deps cockroach

if [ -z `which cockroach` ];then
    lava-test-case "cockroach uninstall" --result pass
else
    lava-test-case "cockroach uninstall" --result fail
fi
rm -rf cockroach-data node2 node3


