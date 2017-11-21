#! /bin/bash 
set -x
basedir=$(cd `dirname $0`;pwd)
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

# create certs
if [ -d certs ];then
    rm -rf certs
fi
mkdir -p  certs
if [ -d my-safe-directory ];then
    rm -rf my-safe-directory
fi
mkdir -p  my-safe-directory
cockroach cert create-ca --certs-dir=certs/ --ca-key=my-safe-directory/ca.key --overwrite  --allow-ca-key-reuse
cockroach cert create-client --certs-dir=certs/ --ca-key=my-safe-directory/ca.key root --overwrite
cockroach cert create-node --certs-dir=certs/ --ca-key=my-safe-directory/ca.key localhost $(hostname) --overwrite

# start cockroach secure ways
if [ -d cockroach-data ];then
    rm -rf cockroach-data
fi
cockroach start --certs-dir=certs/ --host=localhost --http-host=localhost --background
if [ `ps -ef |grep "cockroach start"| grep -v grep |wc -l` -eq 1  ];then
    lava-test-case "cockroach secure start node1" --result pass 
else
    lava-test-case "cockroach secure start node1" --result fail 
fi

if [ -d node2 ];then
    rm -rf node2
fi
if [ -d node3 ];then
    rm -rf node3
fi
cockroach start --certs-dir=certs --store=node2 --host=localhost --port=26258 --http-port=8081 --http-host=localhost --join=localhost:26257 --background
cockroach start --certs-dir=certs --store=node3 --host=localhost --port=26259 --http-port=8082 --http-host=localhost --join=localhost:26257 --background
if [ `ps -ef |grep "cockroach start" | grep -v grep | wc -l` = 3 ] ;then
    lava-test-case "cockroach secure cluster start" --result pass 
else
    lava-test-case "cockroach secure cluster start" --result fail
fi
echo 
echo "cockroach insecure cluster start successed"
echo 

nodestatus1=`cockroach node ls --certs-dir=certs/` 
nodestatus2=`cockroach node status --certs-dir=certs/`
if [ `echo $nodestatus1 | grep "3 rows" -c` -eq 1 ] && [ `echo $nodestatus2 | grep "3 rows" -c` -eq 1  ];then
    lava-test-case "cockroach secure status " --result pass 
else
    lava-test-case "cockroach secure status" --result fail
fi
cockroach sql --certs-dir=certs/ -e "DROP DATABASE IF EXISTS bank;"
res=`cockroach sql --certs-dir=certs/ -e "CREATE DATABASE bank;
                            CREATE TABLE bank.accounts (id INT PRIMARY KEY, balance DECIMAL);
                            INSERT INTO bank.accounts VALUES (1 , 1000.50);
                            SELECT * FROM bank.accounts;"`
if [ `echo $res | grep "1 row" -c` -eq 1 ] ;then
    lava-test-case "cockroach secure node1 executer sql statement" --result pass 
else
    lava-test-case "cockroach secure node1 executer sql statement" --result fail 
fi

node2res=`cockroach sql --certs-dir=certs/ --port=26258 -e "SELECT * FROM bank.accounts"`

if [ `echo $node2res | grep "1 row" -c` -eq 1  ] ;then
    lava-test-case "cockroach secure node2 executer sql statement" --result pass 
else
    lava-test-case "cockroach secure node2 executer sql statement" --result fail 
fi

#ps -ef | grep cockroach | grep node2 | grep -v grep | awk '{print $2}' | xargs kill -9
cockroach quit --certs-dir=certs --port=26258
noderes=`cockroach sql --certs-dir=certs/ -e "SELECT * FROM bank.accounts"`

if [ `echo $noderes | grep "1 row" -c` -eq 1 ] ;then
    lava-test-case "cockroach secure single point failure" --result pass 
else
    lava-test-case "cockroach secure single point failure" --result fail 
fi

#ps -ef | grep cockroach | grep -v grep | awk '{print $2}'| xargs kill -9
cockroach start --certs-dir=certs --store=node2 --host=localhost --port=26258 --http-port=8081 --http-host=localhost --join=localhost:26257 --background

if [ `ps -ef |grep "cockroach start" | grep -v grep | wc -l` -eq 3 ];then
    lava-test-case "cockroach secure restart" --result pass
else
    lava-test-case "cockroach secure restart" --result fail
fi
#cockroach node status --certs-dir=certs/
cockroach quit --certs-dir=certs/ --port=26259
cockroach quit --certs-dir=certs/ --port=26258
cockroach quit --certs-dir=certs/ --port=26257
stopCluster=`ps -ef | grep "cockroach start" | grep -v grep`
if [ -z  "$stopCluster" ];then
    lava-test-case "cockroach secure stop cluster" --result pass
else
    lava-test-case "cockroach secure stop cluster" --result fail
fi

remove_deps cockroach

if [ -z `which cockroach` ];then
    lava-test-case "cockroach uninstall" --result pass
else
    lava-test-case "cockroach uninstall" --result fail
fi
rm -rf cockroach-data node2 node3
rm -rf certs my-safe-directory
set +x
