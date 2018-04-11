#! /bin/bash

#set -x
basedir=$(cd `dirname $0`; pwd)
cd $basedir

. ../../../../utils/sh-test-lib
outDebugInfo

install_deps postgresql
install_deps postgresql-server


lava_path=`pwd`/lava*/bin 


if [ `which pg_ctl`  ];then
    lava-test-case "postgresql_server_install" --result pass
    echo "install ok --------------------"
else
    lava-test-case "postgresql_server_install" --result fail
    exit 1
fi
version=`postgres -V`
if [ x"$version" == x"postgres (PostgreSQL) 9.2.23" ];then
    lava-test-case "postgresql_version" --result pass
else
    lava-test-case "postgresql_version" --result fail
fi

su -l  postgres <<-EOF
      
    set -x
    export PATH=$PATH:${lava_path}
    #if $(`ps -ef |grep "/bin/postgres -D data" -c` -eq 2);then
    ps -ef |grep "/bin/postgres -D data" | grep -v grep
    if [ $? = 0 ];then
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
        lava-test-case "postgresql_init" --result pass
    else
        lava-test-case "postgresql_init" --result fail
    fi
    pg_ctl -D data -l logfile start;
    if [ -f logfile ];then
        grep -i -E  "fatal|error" logfile
	
        if [ $? = 1 ];then
            lava-test-case "postgresql_start" --result pass
        else 
            lava-test-case "postgresql_start" --result fail
        fi
    else
   	lava-test-case "postgresql_start"  --result pass
    fi
    sleep 3 
    pg_ctl -D data status | grep  "server is running"
    if [ \$? = 0 ];then
        lava-test-case "postgresql_status" --result pass
    else
        lava-test-case "postgresql_status" --result fail
    fi
    psql  -c "\l" | grep  template0
    if [ \$? = 0 ];then
        lava-test-case "postgresql_connect_by_unix_socker" --result pass
    else 
        lava-test-case "postgresql_connect_by_unix_socker" --result fail
    fi
    psql -h localhost -p 5432 -c "\l" | grep  template0
    if [ \$? = 0 ];then
        lava-test-case "postgresql_connect_by_tcp" --result pass
    else
        lava-test-case "postgresql_connect_by_tcp" --result fail
    fi
    
    id dbuser
    if [ \$? -eq 0 ];then
	userdel -r dbuser
    fi       
    createuser --superuser  dbuser
    id dbuser
    if [ \$? -eq 0 ];then
        lava-test-case "postgresql_create_user_by_shell" --result pass
    else
        lava-test-case "postgresql_create_user_by_shell" --result fail
    fi
    # username dbuser databasename dbuser
    createdb -O dbuser dbuser 
    psql -U dbuser -c "\l"
    if [ \$? -eq 0 ];then
        lava-test-case "postgresql_create_Non_root_user__by_shell" --result pass
    else
        lava-test-case "postgresql_create__Non_root_user__by_shell" --result fail
    fi
    psql -c "create user dbuser2 with password 'password'"
    psql -c "create database exampledb owner dbuser2"
    psql -c "grant all privileges on database exampledb to dbuser2"
    psql -U dbuser2 -d exampledb -c "\l"
    
    if [ \$? -eq 0 ];then
        lava-test-case "postgresql_create_Non_root_user__by_sql" --result pass
    else
        lava-test-case "postgresql_create_Non_root_user__by_sql" --result fail
    fi
    
    psql  -c "create database test1 "
    if [ \$? = 0 ];then
        lava-test-case "postgresql_create_database_by_sql" --result pass
    else
        lava-test-case "postgresql_create_database_by_sql" --result fail
    fi
    psql  -c "\c test1 "
    if [ \$? = 0 ];then
        lava-test-case "postgresql_connect_new_database" --result pass
    else
        lava-test-case "postgresql_connect_new_database" --result fail
    fi
    psql -d test1 -c "create table account (id INT , account int)"
    if [ \$? = 0 ];then
        lava-test-case "postgresql_create_table" --result pass
    else
        lava-test-case "postgresql_create_table" --result fail
    fi

    psql -d test1 -c "insert into  account values(1 ,1)"
    if [ \$? = 0 ];then
        lava-test-case "postgresql_insert" --result pass
    else
        lava-test-case "postgresql_insert" --result fail
    fi

    psql -d test1 -c  "select * from account"
    if [ \$? = 0 ];then
        lava-test-case "postgresql_select" --result pass
    else
        lava-test-case "postgresql_select" --result fail
    fi
    psql -d test1 -c "\l"
    
    psql -d test1 -c "drop table account"
    if [ \$? = 0 ];then
        lava-test-case "postgresql_drop_table" --result pass
    else
        lava-test-case "postgresql_drop_table" --result fail
    fi
    psql -c "drop database test1"
    if [ \$? = 0 ];then
        lava-test-case "postgresql_drop_database" --result pass
    else
        lava-test-case "postgresql_drop_database" --result fail
    fi

    pg_ctl -D data stop;
    ps -ef|grep "bin/postgres -D data" | grep -v grep 
    if [ \$? = 1  ];then
        lava-test-case "postgresql_stop" --result pass
    else 
        lava-test-case "postgresql_stop" --result fail
    fi
    set +x
    exit
EOF

yum remove -y postgresql postgresql-server
if [ -z `which postgres` ];then
    lava-test-case "postgresql_uninstall" --result pass
else
    lava-test-case "postgresql_uninstall" --result fail
fi

set +x  
exit

