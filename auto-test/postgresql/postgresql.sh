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



user="test"
datadir=/home/${user}/"data"
logfile=/home/${user}/"logfile"

id $user
if [  $? -ne 0 ];then
    useradd -m $user
fi

if [ -d $datadir  ];then
    rm -rf $datadir
fi
mkdir $datadir
version=`pg_config`
if [ `echo $version |grep version` = "VERSION = PostgreSQL 9.2.23"  ];then
    lava-test-case "postgresql version" --result pass
else
    lava-test-case "postgresql version" --result fail
fi

su -c  "pg_ctl -D $datadir  init" $user

if [ -f ${datadir}/pg_hba.conf  ];then
    lava-test-case "postgresql init database" --result pass
    echo "init ok ----------------------"
else
    lava-test-case "postgresql init database" --result fail
fi

chown -R ${user}:root /var/run/postgresql
su -c  "pg_ctl -D $datadir -l $logfile start" $user

status=`su -c $user "pg_ctl -D $datadir status"`
if [ `echo $status | grep "success" -c` -eq 1   ];then
    lava-test-case "postgresql start" --result pass
    echo "start ok -------------------"
else
    lava-test-case "postgresql start" --result fail
fi

#su -c "psql -d postgres -c "CREATE DATABASE test;"" $user
psql -d postgres -c "create database test2"

su -c "pg_ctl -D $datadir stop" $user

su -c "rm -rf $datadir" $user




