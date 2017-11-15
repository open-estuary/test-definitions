#! /bin/bash

set -x
export PS4='+{$LINENO:${FUNCNAME[0]}} '

basedir=$(cd `dirname $0`;pwd)
cd $basedir
export basedir

. ../../utils/sys_info.sh
. ../../utils/sh-test-lib

. ./hive.sh


function hive_install_config() {

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
}
# 3 

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

        unzip -f ../ml-100k.zip

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

        hive -e "LOAD DATA LOCAL INPATH '../ml-100k/u.data' OVERWRITE INTO TABLE u_data;"
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
		hdfs dfs -test -d /text/in
		if [ $? ];then
			hdfs dfs -rm -r /text/in
		fi
        hdfs dfs -mkdir -p /text/in/day20
        hdfs dfs -mkdir -p /text/in/day21
        hdfs dfs -put -f ../hive-data1.txt  /text/in/day20/20.txt &&
        hdfs dfs -put -f ../hive-data2.txt  /text/in/day21/21.txt
        print_info $? "hive create outer table data"
	
	# 0174 --> | 
        hive -e  "create external table outer_tb(seq int, name string , year int , city string )
        partitioned by (day int)
        ROW FORMAT DELIMITED
        FIELDS TERMINATED BY '\073'
        STORED AS TEXTFILE;"
        print_info $? "hive create outer table"

        hive -e "alter table outer_tb  add partition (day=20) location '/text/in/day20'"
        hive -e "alter table outer_tb  add partition (day=21) location '/text/in/day21'"
        
        print_info $? "hive outer table bind data"

        hive -e "show partitions outer_tb;" > tmp.log
        cat tmp.log 
		res=`grep day tmp.log -c` 
		if [ $res -eq 2 ];then
			true
		else
			false
		fi
		print_into $? "hive partitions count"

        hive -e "select count(*) from outer_tb ;" > tmp.log 
        res=`cat tmp.log`
        if [ $res -ge 1 ]; then
            true
        else
            false
        fi

        print_info $? "hive outer table select operator"

        hdfs dfs -put ../hive-data2.txt /text/in/day20
        hive -e "select count(*) from outer_tb ;" > tmp.log 
        res1=`cat tmp.log`
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

function hive_partitioned_table() {
	hive -e "create database if not exists mydb;"
	print_info $? "hive create database"
	hive -e "use mydb;"
	print_info $? "hive switch database"
	
	hive -e "create table partTb (seq int , name string , year int ,city string )
		partitioned by (day int)
		ROW FORMAT DELIMITED FIELDS TERMINATED  BY '\073'
		STORED AS TEXTFILE;"
	print_info $? "hive create partitioned table"
	hive -e "load data local inpath '../hive-data1.txt' into table partTb partition (day=20);" && \
	hive -e "load data local inpath '../hive-data2.txt' into table partTb partition (day=21);"
	print_info $? "hive load data to partition table"
	hdfs dfs -test -e /user/hive/warehouse/parttb/day=20
	print_info $? "hive partition table in hdfs struct"
	
	hive -e "select * from partTb where day=20;" > tmp.log
	res=`wc -l tmp.log | cut -d " " -f 1`
	if [ $res -gt 1 ];then
		true
	else
		false
	fi
	print_info $? "hive select partition table"
		

	hive -e "drop table partTb;"
	print_info $? "hive drop partition table"
	hdfs dfs -test -e /user/hive/warehouse/parttb/day=20/hive-data1.txt
	if [ $? -eq 0 ];then
		false
	else
		true
	fi
	print_info $? "hive drop partition table that can delete data"
}

function hive_bucket_table(){
	
	# 073 --> ;
	hive -e "create table if not exists buckettext (seq int , name string , yarn int , city string )
		ROW FORMAT DELIMITED FIELDS TERMINATED BY '\073' 
		STORED AS TEXTFILE;"
	hive -e "LOAD DATA LOCAL INPATH '../hive-data1.txt' into table buckettext"
	
	hive -e "create table if not exists bucket(seq int , name string , yarn int , city string )
			clustered by(city) sorted by (city) into 4 buckets
			row format delimited fields terminated by '\t'
			stored as textfile;"
	print_info $? "hive create bucket table"
	
	hive -e "set hive.enforce.bucketing=true;insert overwrite table bucket select * from buckettext;"
	print_info $? "hive load data to bucket table"
	
	hdfs dfs -test -e /user/hive/warehouse/bucket/000000_0 && hdfs dfs -test -e /user/hive/warehouse/bucket/000003_0
	print_info $? "hive bucket data on hdfs"
	
	hive -e "select * from bucket tablesample(bucket 1 out of 2 on city);" > tmp.log
	res=`wc -l tmp.log | cut -d " " -f 1`
	if [ $res -ge 1 ];then
		true
	else
		false
	fi
	print_info $? "hive bucket table sample"
	hive -e "select * from bucket;" > tmp.log
	print_info $? "hive bucket table select"
	
	hive -e "drop table bucket"
	print_info $? "hive exec drop bucket table"
	hdfs dfs -test -d /user/hive/warehouse/bucket
	if [ $? -eq 0 ];then
		false
	else
		true
	fi
	print_info $? "hive drop bucket table on same delete file on hdfs"
}

function hive_uninstall(){
	echo $basedir
	cd $basedir
	rm -rf apache-hive*
	hdfs dfs -rm -r /user/hive
	sed -i "/HIVE_HOME/d" ~/.bashrc
	export HIVE_HOME 

}


hive_install_config

cd $HIVE_HOME
hive_init

hive_base_client_command

hive_inner_table 
hive_outer_table
hive_partitioned_table
hive_bucket_table
hive_uninstall
