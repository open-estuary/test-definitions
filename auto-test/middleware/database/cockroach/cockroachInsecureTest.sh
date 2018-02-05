#! /bin/bash 

set -x
basedir=$(cd `dirname $0` ;pwd)
cd $basedir 
. ../../../../lib/sh-test-lib 


install_deps cockroach

if [ `which cockroach`  ] ;then
    lava-test-case "cockroach_install " --result pass 
	echo "cockrock install ok"
else
    lava-test-case "cockroach_install" --result fail 
fi

version=`cockroach_version | grep "Build Tag:" | awk '{print $3}'`
if [ x"$version" = x"v1.0.3"  ];then
    lava-test-case "cockroach_version" --result pass 
	echo "version ok"
else
    lava-test-case "cockroach_version" --result fail 
fi
if [ -d cockroach-data ];then
    rm -rf cockroach-data
fi
cockroach start --insecure --host localhost --background   
if [ `ps -ef | grep "cockroach start" | grep -v grep | wc -l` -eq 1 ];then
    lava-test-case "cockroach_start_node1" --result pass 
	echo "cockroach start ok ----------------"
else
    lava-test-case "cockroach_start_node1" --result fail 
fi
echo ----------------

if [ -d node2 ];then
    rm -rf node2
fi
cockroach start --insecure --store=node2 --host=localhost --port=26258 --http-port=8081 --join=localhost:26257 --background
if [ -d node3 ];then
    rm -rf node3
fi
cockroach start --insecure --store=node3 --host=localhost --port=26259 --http-port=8082 --join=localhost:26257 --background

if [ `ps -ef |grep "cockroach start"| grep -v grep | wc -l` = 3 ] ;then
    lava-test-case "cockroach_cluster_start" --result pass 
	echo "cockroach_cluster_start ok ------------------------"
else
    lava-test-case "cockroach_cluster_start" --result fail
    echo "cockroach_cluster_start failed"
    exit 1
fi
echo 
echo "cockroach insecure cluster start successed"
echo 

nodestatus1=`cockroach node ls --insecure` 
nodestatus2=`cockroach node status --insecure`
if `echo $nodestatus1 | grep "3 rows"` && `echo $nodestatus2 | grep "3 rows"`;then
    lava-test-case "cockroach_status " --result pass
	echo "cockroach_status ok ------------------------" 
else
    lava-test-case "cockroach_status" --result fail
fi

echo 
echo "cockroach_status ok"
echo 

cockroach sql --insecure -e "DROP DATABASE IF EXISTS bank;"
res=`cockroach sql --insecure -e "CREATE DATABASE bank;
				  CREATE TABLE bank.accounts (id INT PRIMARY KEY , balance DECIMAL);
				  INSERT INTO bank.accounts VALUES (1 , 1000.50);
				  SELECT * FROM bank.accounts;"`
if [ `echo $res | grep "1 row" -c` -ge 1 ] ;then
    lava-test-case "cockroach_node1_executer_sql_statement" --result pass 
else
    lava-test-case "cockroach_node1_executer_sql_statement" --result fail 
fi

node2res=`cockroach sql --insecure --port=26258 -e "SELECT * FROM bank.accounts"`

if [  `echo $node2res | grep "1 row" -c` -ge 1  ] ;then
    lava-test-case "cockroach_node2_executer_sql_statement" --result pass 
else
    lava-test-case "cockroach_node2_executer_sql_statement" --result fail 
fi

#ps -ef | grep cockroach | grep node2 | grep -v grep | awk '{print $2}' | xargs kill -9
cockroach quit --insecure --port 26258
noderes=`cockroach sql --insecure -e "SELECT * FROM bank.accounts"`

if [ `echo "$noderes"| grep "1 row" -c` -ge 1  ] ;then
    lava-test-case "cockroach_single_point_failure" --result pass 
else
    lava-test-case "cockroach_single_point_failure" --result fail 
fi

#ps -ef | grep cockroach | grep -v grep | awk '{print $2}'| xargs kill -9

cockroach start --insecure --store=node2 --host=localhost --port=26258 --http-port=8081 --join=localhost:26257 --background

if [ `ps -ef |grep "cockroach start" | grep -v grep | wc -l` -eq 3 ];then
    lava-test-case "cockroach_restart" --result pass
else
    lava-test-case "cockroach_restart" --result fail
fi

cockroach quit --insecure --port 26257
cockroach quit --insecure --port 26258
cockroach quit --insecure --port 26259

stopCluster=`ps -ef | grep "cockroach start" | grep -v grep`
if [ -z  "$stopCluster" ];then
    lava-test-case "cockroach_stop_cluster" --result pass
else
    lava-test-case "cockroach_stop_cluster" --result fail
fi

remove_deps cockroach

if [ -z `which cockroach` ];then
    lava-test-case "cockroach_uninstall" --result pass
else
    lava-test-case "cockroach_uninstall" --result fail
fi
rm -rf cockroach-data node2 node3

set +x
