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

export user="test"

id $user
if [  $? -ne 0 ];then
    useradd -b /home  -m $user
fi
chown -R ${user}:${user} /var/run/postgresql

su - $user <<EOF
    set -x
    pwd;
    whoami;
    if [ -d data ];then
        rm -rf data logfile
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
    
    env 
    pwd
    id
    psql  -d postgres -c "\l"

    psql -d postgres -c "create database test1 "
    psql -d postgres -c "\c test1 "
    psql -d postgres -c "create table account (id INT , account int)"
    psql -d postgres -c "insert into  account values(1 ,1)"
    psql -d postgres -c "select * from account"
    psql -d test1 -c "\l"
    exit

    pg_ctl -D data stop;
     
    rm -rf data
    cat logfile
    rm -f logfile
    set +x
    exit;
EOF
exit

sudo -u test -s /bin/bash ./sql.sh
exit

if [ -d /home/${user}/$datadir  ];then  
    rm -rf /home/${user}/$datadir
fi
    sudo -u $user mkdir /home/${user}/$datadir
    sudo -u $user pg_ctl -D /home/${user}/$datadir init

    sudo -u $user pg_ctl -D /home/${user}/$datadir -l /home/${user}/$log start

    sudo -u $user pg_ctl -D /home/${user}/$datadir status
set +x




