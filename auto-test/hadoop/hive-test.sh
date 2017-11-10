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

hive -e "! ls" > my.log
print_info $? "hive exec shell command"

hive -e "dfs -ls /"
print_info $? "hive exec dfs command"

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
print_info $? "hive base select"

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

hdfs dfs -put ml-100k /
hive -e  "create external table u_user(id int,age int,sex string,profession string,nameId string)
     ROW FORMAT DELIMITED
     FIELDS TERMINATED BY '|'
     STORED AS TEXTFILE
     location '/ml-200k/u.user';"

FROM u_user user
INSERT OVERWRITE TABLE pa PARTITION(dt='2008-06-08', country='US')
SELECT pvs.viewTime, pvs.userid, pvs.page_url, pvs.referrer_url, null, null, pvs.ip
WHERE pvs.country = 'US';

hive -e "select count(*) from u_user where sex = 'M'"




