#! /bin/bash

set -x
export PS4='+{$LINENO:${FUNCNAME[0]}} '

basedir=$(cd `dirname $0`;pwd)
cd $basedir
export basedir

. ../../utils/sys_info.sh
. ../../utils/sh-test-lib

. ./hive.sh

# 1 start hadoop
start_hadoop 
if [ $? ];then
    lava-test-case "hive: hadoop running" --result pass
else
    lava-test-case "hive: hadoop running" --result fail
    exit 1
fi

hive_create_dir_on_hdfs

# 2 install hive
cd $basedir
hive_install

hive_edit_config

# 3 
cd $HIVE_HOME

function hive_init() {
        schematool -initSchema -dbType derby  
        if [ $? ];then
            echo "init hive ok"
            lava-test-case "hive init metastore" --result pass
        else
            lava-test-case "hive init metastore" --result fail
            exit 1
        fi
        # 4 
        hive -S -e "show databases;"
        if [ $? ];then
             lava-test-case "hive show databases" --result pass
        else
            lava-test-case "hive show databases" --result fail
        fi
}

function hive_base_client_command() {
        hive -e "! ls" > my.log
        print_info $? "hive exec shell command"

        hive -e "dfs -ls /"
        print_info $? "hive exec dfs command"
}

function hive_inner_table() {
        if [ ! -f ../ml-100k.zip ];then
            wget http://files.grouplens.org/datasets/movielens/ml-100k.zip -O ../ml-100k.zip
            print_info $? "hive download test data"
        fi
        if [ ! `which unzip` ];then
            yum install unzip -y
        fi

        unzip ../ml-100k.zip

        hive -e "CREATE TABLE u_data (
                userid INT,
                movieid INT,
                rating INT,
                unixtime STRING)
        ROW FORMAT DELIMITED
        FIELDS TERMINATED BY '\t'
        STORED AS TEXTFILE;"
        print_info $? "hive create inner table"

        hdfs dfs -test -e /user/hive/warehouse/u_data
        print_info $? "hive view data in hdfs"

        hive -e "LOAD DATA LOCAL INPATH './ml-100k/u.data' OVERWRITE INTO TABLE u_data;"
        print_info $? "hive load data "

        hive -e "insert into table u_data values(1,3,4,"121212121");"
        print_info $? "hive insert into table"

        hive -e "select count(*) from u_data;"
        print_info $? "hive base select count(*)"

        cp ${basedir}/hive-add-file.sql .
        print_info $? "hive create sql file"

        cp ${basedir}/weekday_mapper.py .
        print_info $? "hive create outer script file"

        hive -f "hive-add-file.sql"
        print_info $? "hive batch mode commands"

        hive -e "SELECT weekday, COUNT(*)
        FROM u_data_new
        GROUP BY weekday;"
        print_info $? "hive exec outer script"
}

function hive_outer_table(){
        hdfs dfs -mkdir -p /text/in/day20
        hdfs dfs -mkdir -p /text/in/day21
        hdfs dfs -put -f ../hive-data1.txt  /text/in/day20/20.txt &&
        hdfs dfs -put -f ../hive-data2.txt  /text/in/day21/21.txt
        print_info $? "hive create outer table data"

        hive -e  "create external table outer_tb(seq int, name string , year int , city string , day int)
        partition by (day int)
        ROW FORMAT DELIMITED
        FIELDS TERMINATED BY '|'
        STORED AS TEXTFILE;"
        print_info $? "hive create outer table"

        hive -e "alter table outer_tb  add partition (day=20) location '/text/in/day20'"
        hive -e "alter table outer_tb  add partition (day=21) location '/text/in/day21'"
        
        print_info $? "hive outer table bind data"

        hive -e "show partitions outer_tb;" > tmp.log
        cat tmp.log 



        hive -e "select count(*) from outer_tb ;" > tmp.log 
        res=`wc -l tmp.log | cut -d " " -f 1`
        if [ $res -ge 1 ]; then
            true
        else
            false
        fi

        print_info $? "hive outer table select operator"

        hdfs dfs -put ../hive-data2.txt /text/in/day20
        hive -e "select count(*) from outer_tb ;" > tmp.log 
        res1=`wc -l tmp.log`
        if [ $res1 -gt $res  ];then
            true
        else
            false
        fi
        print_info $? "hive outer table dynamic add data"

        hive -e "drop table outer_tb"
        print_info $? "hive drop outer table "

        hdfs dfs -test -e  /text/in/day20/20.txt 
        print_info $? "hive outer table should not delete outer data"

}

function hive-bucket-table() {
   echo  

}

hive_init
hive_base_client_command
hive_inner_table 
hive_outer_table

