#! /bin/bash

. ./hadoop.sh

function hive_install_innter(){
	pwd
    if test ! -d /var/bigdata/hive/
    then
        mkdir -p /var/bigdata/hive/
    fi 
    pushd  /var/bigdata/hive 
	if test -f apache-hive-2.1.1-bin.tar.gz ;
    then
		if [ -d apache-hive-2.1.1-bin ];then
			rm -rf apache-hive-2.1.1-bin
		fi
	else
		wget -c -q  http://mirrors.shuosc.org/apache/hive/hive-2.1.1/apache-hive-2.1.1-bin.tar.gz
		if [ $? ];then
			lava-test-case "hive_download_bin_file" --result pass
		else
			lava-test-case "hive_download_bin_file" --result fail
			exit 1
		fi
	fi
	tar  -zxf apache-hive-2.1.1-bin.tar.gz
    local hivedir=`pwd`/apache-hive-2.1.1-bin
	sed -i "/HIVE_HOME/d" ~/.bashrc
	export HIVE_HOME=$hivedir &&
	echo "export HIVE_HOME=$hivedir" >> ~/.bashrc &&
	echo 'export PATH=$PATH:$HIVE_HOME/bin' >> ~/.bashrc 
	print_info $? "hive_config_system_envriment_parament"
	source ~/.bashrc 	
	print_info $? "hive_install"
    popd 
}

function hive_edit_config(){
    CP=`which cp --skip-alias`
    pwd 
    $CP -f  ./hive-site.xml $HIVE_HOME/conf/hive-site.xml
    	
	res=`diff  $HIVE_HOME/conf/hive-default.xml.template $HIVE_HOME/conf/hive-site.xml | grep "/tmp/hive" -c`
	if [ $res -ge 3 ];then
		lava-test-case "hive_edit_config_file" --result pass
	else 
		lava-test-case "hive_edit_config_file" --result fail
	fi

}

function isDfsRunning(){
    local res1=`jps | grep -i namenode | grep -vi secondarynamenode | grep -vc Jps`
    local res2=`jps | grep -i datanode | grep -vc Jps`
    local res3=`jps | grep -i secondarynamenode | grep -vc Jps`
    if [ $res1 -eq 1 ] && [ $res2 -eq 1 ] && [ $res3 -eq 1 ] ;then
        return 0
    else
        return 1
    fi
}

function isYarnRunning() {
	local res1=`jps | grep -i nodemanager | grep -vc Jps`
	local res2=`jps | grep -i resourcemanager | grep -vc Jps`
	if [ $res1 -eq 1 ] && [ $res2 -eq 1 ];then
		return 0
	else
		return 1
	fi
}

function start_hadoop(){
	
	isDfsRunning && isYarnRunning
	if [ $? -eq 0 ];then
		return 0
	fi
	
	install_jdk
	install_hadoop
	hadoop_ssh_nopasswd
	hadoop_config_base
	hadoop_namenode_format
	hadoop_config_yarn
	
	$HADOOP_HOME/sbin/start-dfs.sh
	
	$HADOOP_HOME/sbin/start-yarn.sh
	
	isDfsRunning
	local res1=$?
	isYarnRunning
	local res2=$?
	if [ $res1 -eq 0 ] && [ $res2 -eq 0 ];then
		return 0
	else
		return 1
	fi
}
function hive_create_dir_on_hdfs() {
	hdfs dfs -test -e /tmp
	if [ $? ];then
		hdfs dfs -rm -f -r /tmp
	fi
	hdfs dfs -mkdir /tmp
	print_info $? "hive_create_tmp_dir"

	hdfs dfs -test -e /user/hive/warehouse
	if [ $? ];then
		hdfs dfs -rm -f -r /user/hive/warehouse
		sleep 3
	fi
	hdfs dfs -mkdir -p /user/hive/warehouse	 
	print_info $?  'hive_create_/user/hive/warehouse'
	
	hdfs dfs -chmod g+w /tmp /user/hive/warehouse
	print_info $? "hive_change_work_dir_mod"	
 
}

function hive_install() {

	# 2 install hive
	hive_install_innter

	hive_edit_config
}

function hive_start_hadoop(){

	# 1 start hadoop
	start_hadoop 
	if [ $? -eq 0 ];then
    	lava-test-case "hive_hadoop_running" --result pass
	else
        lava-test-case "hive_hadoop_running" --result fail
    	exit 1
	fi
    
	hive_create_dir_on_hdfs
}
 

function hive_init() {
    schematool -initSchema -dbType derby | grep failed 
    if [ ! $? ];then
        echo "init hive ok"
        lava-test-case "hive_init_metastore" --result pass
    else
        lava-test-case "hive_init_metastore" --result fail
        exit 1
    fi
    # 4 
     hive -S -e "show databases;"
     if [ $? ];then
         lava-test-case "hive_show_databases" --result pass
     else
         lava-test-case "hive_show_databases" --result fail   
     fi
}

function hive_base_client_command() {
        hive -e "! ls" > my.log
        print_info $? "hive_exec_shell_command"

        hive -e "dfs -ls /"
        print_info $? "hive_exec_dfs_command"
}

function hive_inner_table() {
        if [ ! -f ./ml-100k.zip ];then
            wget -c http://files.grouplens.org/datasets/movielens/ml-100k.zip -O ml-100k.zip
            print_info $? "hive_download_test_data"
        fi
        if [ ! `which unzip` ];then
            yum install unzip -y
        fi

        unzip -f ./ml-100k.zip

        hive -e "CREATE TABLE u_data (
                userid INT,
                movieid INT,
                rating INT,
                unixtime STRING)
        ROW FORMAT DELIMITED
        FIELDS TERMINATED BY '\t'
        STORED AS TEXTFILE;"
        print_info $? "hive_create_inner_table"

        hdfs dfs -test -e /user/hive/warehouse/u_data
        print_info $? "hive_view_data_in_hdfs"

        hive -e "LOAD DATA LOCAL INPATH './ml-100k/u.data' OVERWRITE INTO TABLE u_data;"
        print_info $? "hive_load_data "

        hive -e "insert into table u_data values(1,3,4,"121212121");"
        print_info $? "hive_insert_into_table"

        hive -e "select count(*) from u_data;"
        print_info $? "hive base select count(*)"

        cp ${basedir}/hive-add-file.sql .
        print_info $? "hive_create_sql_file"

        cp ${basedir}/weekday_mapper.py .
        print_info $? "hive_create_outer_script_file"

        hive -f "hive-add-file.sql"
        print_info $? "hive_batch_mode_commands"

        hive -e "SELECT weekday, COUNT(*)
        FROM u_data_new
        GROUP BY weekday;"
        print_info $? "hive_exec_outer_script"
}

function hive_outer_table(){
		hdfs dfs -test -d /text/in
		if [ $? ];then
			hdfs dfs -rm -r /text/in
		fi
        hdfs dfs -mkdir -p /text/in/day20
        hdfs dfs -mkdir -p /text/in/day21
        hdfs dfs -put -f ./hive-data1.txt  /text/in/day20/20.txt &&
        hdfs dfs -put -f ./hive-data2.txt  /text/in/day21/21.txt
        print_info $? "hive_create_outer_table_data"
	
	# 0174 --> | 
        hive -e  "create external table outer_tb(seq int, name string , year int , city string )
        partitioned by (day int)
        ROW FORMAT DELIMITED
        FIELDS TERMINATED BY '\073'
        STORED AS TEXTFILE;"
        print_info $? "hive_create_outer_table"

        hive -e "alter table outer_tb  add partition (day=20) location '/text/in/day20'"
        hive -e "alter table outer_tb  add partition (day=21) location '/text/in/day21'"
        
        print_info $? "hive_outer_table_bind_data"

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

        print_info $? "hive_outer_table_select_operator"

        hdfs dfs -put ./hive-data2.txt /text/in/day20
        hive -e "select count(*) from outer_tb ;" > tmp.log 
        res1=`cat tmp.log`
        if [ $res1 -gt $res  ];then
            true
        else
            false
        fi
        print_info $? "hive_outer_table_dynamic_add_data"

        hive -e "drop table outer_tb"
        print_info $? "hive_drop_outer_table "

        hdfs dfs -test -e  /text/in/day20/20.txt 
        print_info $? "hive_outer_table_should_not_delete_outer_data"

}

function hive_partitioned_table() {
	hive -e "create database if not exists mydb;"
	print_info $? "hive_create_database"
	hive -e "use mydb;"
	print_info $? "hive_switch_database"
	
	hive -e "create table partTb (seq int , name string , year int ,city string )
		partitioned by (day int)
		ROW FORMAT DELIMITED FIELDS TERMINATED  BY '\073'
		STORED AS TEXTFILE;"
	print_info $? "hive_create_partitioned_table"
	hive -e "load data local inpath './hive-data1.txt' into table partTb partition (day=20);" && \
	hive -e "load data local inpath './hive-data2.txt' into table partTb partition (day=21);"
	print_info $? "hive_load_data_to_partition_table"
	hdfs dfs -test -e /user/hive/warehouse/parttb/day=20
	print_info $? "hive_partition_table_in_hdfs_struct"
	
	hive -e "select * from partTb where day=20;" > tmp.log
	res=`wc -l tmp.log | cut -d " " -f 1`
	if [ $res -gt 1 ];then
		true
	else
		false
	fi
	print_info $? "hive_select_partition_table"
		

	hive -e "drop table partTb;"
	print_info $? "hive_drop_partition_table"
	hdfs dfs -test -e /user/hive/warehouse/parttb/day=20/hive-data1.txt
	if [ $? -eq 0 ];then
		false
	else
		true
	fi
	print_info $? "hive_drop_partition_table_that_can_delete_data"
}

function hive_bucket_table(){
	
	# 073 --> ;
	hive -e "create table if not exists buckettext (seq int , name string , yarn int , city string )
		ROW FORMAT DELIMITED FIELDS TERMINATED BY '\073' 
		STORED AS TEXTFILE;"
	hive -e "LOAD DATA LOCAL INPATH './hive-data1.txt' into table buckettext"
	
	hive -e "create table if not exists bucket(seq int , name string , yarn int , city string )
			clustered by(city) sorted by (city) into 4 buckets
			row format delimited fields terminated by '\t'
			stored as textfile;"
	print_info $? "hive_create_bucket_table"
	
	hive -e "set hive.enforce.bucketing=true;insert overwrite table bucket select * from buckettext;"
	print_info $? "hive_load_data_to_bucket_table"
	
	hdfs dfs -test -e /user/hive/warehouse/bucket/000000_0 && hdfs dfs -test -e /user/hive/warehouse/bucket/000003_0
	print_info $? "hive_bucket_data_on_hdfs"
	
	hive -e "select * from bucket tablesample(bucket 1 out of 2 on city);" > tmp.log
	res=`wc -l tmp.log | cut -d " " -f 1`
	if [ $res -ge 1 ];then
		true
	else
		false
	fi
	print_info $? "hive_bucket_table_sample"
	hive -e "select * from bucket;" > tmp.log
	print_info $? "hive_bucket_table_select"
	
	hive -e "drop table bucket"
	print_info $? "hive_exec_drop_bucket_table"
	hdfs dfs -test -d /user/hive/warehouse/bucket
	if [ $? -eq 0 ];then
		false
	else
		true
	fi
	print_info $? "hive_drop_bucket_table_on_same_delete_file_on_hdfs"
}

function hive_uninstall(){
	echo $basedir
	cd $basedir
	rm -rf apache-hive*
	hdfs dfs -rm -r /user/hive
	sed -i "/HIVE_HOME/d" ~/.bashrc
	export HIVE_HOME 

}


