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
    exit 1
fi
version=`postgres -V`
if [ $version = "postgres (PostgreSQL) 9.2.23" ];then
    lava-test-case "postgresql version" --result pass
else
    lava-test-case "postgresql version" --result fail
fi

su -l - postgres <<-EOF
      
    set -x
    #if $(`ps -ef |grep "/bin/postgres -D data" -c` -eq 2);then
    ps -ef |grep "/bin/postgres -D data" | grep -v grep
    if [ \$? = 0 ];then
        pg_ctl -D data stop
	sleep 5
    fi
    if [ -d data ];then
        rm -rf data 
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
    if [ -f logfile ];then
        grep -i -E  "fatal|error" logfile
	
        if [ \$? = 1 ];then
            lava-test-case "postgresql start" --result pass
        else 
            lava-test-case "postgresql start" --result fail
        fi
    else
   	lava-test-case "postgresql start"  --result pass
    fi
    sleep 3 
    pg_ctl -D data status | grep  "server is running"
    if [ \$? = 0 ];then
        lava-test-case "postgresql status" --result pass
    else
        lava-test-case "postgresql status" --result fail
    fi
    psql  -c "\l" | grep  template0
    if [ \$? = 0 ];then
        lava-test-case "postgresql connect by unix socker" --result pass
    else 
        lava-test-case "postgresql connect by unix socker" --result fail
    fi
    psql -h localhost -p 5432 -c "\l" | grep  template0
    if [ \$? = 0 ];then
        lava-test-case "postgresql connect by tcp" --result pass
    else
        lava-test-case "postgresql connect by tcp" --result fail
    fi
    
    id dbuser
    if [ \$? -eq 0 ];then
	userdel -r dbuser
    fi       
    createuser --superuser  dbuser
    id dbuser
    if [ \$? -eq 0 ];then
        lava-test-case "postgresql create user by shell" --result pass
    else
        lava-test-case "postgresql create user by shell" --result fail
    fi
    # username dbuser databasename dbuser
    createdb -O dbuser dbuser 
    psql -U dbuser -c "\l"
    if [ \$? -eq 0 ];then
        lava-test-case "postgresql create Non root user  by shell" --result pass
    else
        lava-test-case "postgresql create  Non root user  by shell" --result fail
    fi
    psql -c "create user dbuser2 with password 'password'"
    psql -c "create database exampledb owner dbuser2"
    psql -c "grant all privileges on database exampledb to dbuser2"
    psql -U dbuser2 -d exampledb -c "\l"
    
    if [ \$? -eq 0 ];then
        lava-test-case "postgresql create Non root user  by sql" --result pass
    else
        lava-test-case "postgresql create Non root user  by sql" --result fail
    fi
    
    psql  -c "create database test1 "
    if [ \$? = 0 ];then
        lava-test-case "postgresql create database by sql" --result pass
    else
        lava-test-case "postgresql create database by sql" --result fail
    fi
    psql  -c "\c test1 "
    if [ \$? = 0 ];then
        lava-test-case "postgresql connect new database" --result pass
    else
        lava-test-case "postgresql connect new database" --result fail
    fi
    psql -d test1 -c "create table account (id INT , account int)"
    if [ \$? = 0 ];then
        lava-test-case "postgresql create table" --result pass
    else
        lava-test-case "postgresql create table" --result fail
    fi

    psql -d test1 -c "insert into  account values(1 ,1)"
    if [ \$? = 0 ];then
        lava-test-case "postgresql insert" --result pass
    else
        lava-test-case "postgresql insert" --result fail
    fi

    psql -d test1 -c  "select * from account"
    if [ \$? = 0 ];then
        lava-test-case "postgresql select" --result pass
    else
        lava-test-case "postgresql select" --result fail
    fi
    psql -d test1 -c "\l"
    
    psql -d test1 -c "drop table account"
    if [ \$? = 0 ];then
        lava-test-case "postgresql drop table" --result pass
    else
        lava-test-case "postgresql drop table" --result fail
    fi
    psql -c "drop database test1"
    if [ \$? = 0 ];then
        lava-test-case "postgresql drop database" --result pass
    else
        lava-test-case "postgresql drop database" --result fail
    fi

    pg_ctl -D data stop;
    ps -ef|grep "bin/postgres -D data" | grep -v grep 
    if [ \$? = 1  ];then
        lava-test-case "postgresql stop" --result pass
    else 
        lava-test-case "postgresql stop" --result fail
    fi
    set +x
    exit
EOF

yum remove -y postgresql postgresql-server
if [ -z `which postgres` ];then
    lava-test-case "postgresql uninstall" --result pass
else
    lava-test-case "postgresql uninstall" --result fail
fi

set +x  
exit

