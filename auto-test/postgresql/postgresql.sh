#! /bin/bash

set -x
basedir=$(cd `dirname $0`; pwd)
cd $basedir

. ../../lib/sh-test-lib

install_deps postgresql
install_deps postgresql-server

if [ `which pg_ctl`  ];then
    lava-test-case "postgresql server install" --result pass
    echo "install ok --------------------"
else
    lava-test-case "postgresql server install" --result fail
fi

su - postgres <<EOF
    set -x
    if [ -d data ];then
        rm -rf data logfile
    fi
    if [ -f logfile ];then
        rm -f logfile
    fi
    mkdir data ;
    pg_ctl -D data init;
    if [ -f data/pg_hba.conf  ];then
        lava-test-case "postgresql init" --result pass
    else
        lava-test-case "postgresql init" --result fail
    fi
    pg_ctl -D data -l logfile start;
    if [ `grep -iEc "fatal|error"  logfile` -eq 0 ];then
        lava-test-case "postgresql start" --result pass
    else 
        lava-test-case "postgresql start" --result fail
    fi
    status=$(pg_ctl -D data status)

    echo $status
    if [ `echo $status | grep -c "server is running"` -eq 1 ];then
        lava-test-case "postgresql status" --result pass
    else
        lava-test-case "postgresql status" --result fail
    fi
    
    sleep 5
    psql  -c "\l"

    psql  -c "create database test1 "
    psql  -c "\c test1 "
    psql  "create table account (id INT , account int)"
    psql  "insert into  account values(1 ,1)"
    psql  "select * from account"
    psql -d test1 -c "\l"

    

    pg_ctl -D data stop;
     
    set +x
    exit;
EOF
exit

