#!/bin/bash

############################################################################
#用例名称：postgresql
#用例功能：
#	1. 版本检查：9.2
#	2. 数据库初始化：
#	3. 创建用户：创建普通用户test
#	4. 基本查询功能：使用select进行查询
#	5. 压力测试
#作者    ：章汪群 zwx644970
#完成时间：2019/5/6
#版本号  ： V0.1
##############################################################################

################################初始化变量################################
path=`pwd`
INSTALL_DIR=../../../../../estuary-app/app_install_scripts # 指定安装脚本所在目录
INSTALL_SCRIPT=${INSTALL_DIR}/postgreSQL.sh # 指定安装脚本
PY_JSON_TRANSFOR=${path}/../../../../utils/result_transfor_json.py # 将测试结果转为json的python脚本
dir=/usr/local/pgsql/pgsql_data

################################导入公共函数################################
PUBLIC_UTILS_DIR=${path}/../../../../utils/
. ${PUBLIC_UTILS_DIR}/sys_info.sh
. ${PUBLIC_UTILS_DIR}/sh-test-lib
. ${PUBLIC_UTILS_DIR}/test_case_common.inc
. ${PUBLIC_UTILS_DIR}/test_case_public.sh

################################获取脚本名称作为测试用例名称################################
test_name=$(basename $0 | sed -e 's/\.sh//')

################################@创建log目录################################
TMPDIR=${path}/logs
mkdir -p ${TMPDIR}

################################存放脚本处理中间状态/值等################################
#!!!!!!!!可否不使用中间状态文件,直接用字符串存储中间数据!!!!!!!!!!!
#TMPFILE=${TMPDIR}/${test_name}.tmp

################################存放每个测试步骤的执行结果################################
RESULT_FILE=${TMPDIR}/${test_name}_rst.log

#自定义函数区域（可选）
#function xxx()
#	{}

function check_release()
{ 
    ###@检测发行版### 
    cat /etc/os-release
    uname -a
	dmidecode --type processor | grep Version
}

################################初始化环境包含（安装所需要的包）################################
function init_env()
{
	###@开启日志入库时间### 
	#get_starttime
	
	###@判断是否为root用户	
	! check_root && error_msg "Please run this script as root."   
	
	###@调用安装脚本###
	chmod 777 ${INSTALL_SCRIPT}
	bash ${INSTALL_SCRIPT}
	
	###@检查结果文件是否存在，创建结果文件###
	check_resultfile ${RESULT_FILE}
}

################################测试函数实现区域################################
###@test1###
function test1()
{
	###@数据库初始化###	
	rm -rf "${dir}"
	mkdir "${dir}"
	useradd postgres
	chown postgres "${dir}"	
	cd /usr/local/pgsql/bin/
	su postgres -c "./initdb -D ../pgsql_data/"
	if [ $? == 0 ];then
		write_result "${RESULT_FILE}" "postgresql_initialization_command" "pass"
	else
		write_result "${RESULT_FILE}" "postgresql_initialization_command" "fail"
	fi
	###启动数据库###
	su postgres -c "./postgres -D ../pgsql_data/&"
	sleep 5
	ps -efww |grep "postgres -D"|grep -v grep
	if [ $? == 0 ];then
		write_result "${RESULT_FILE}" "postgresql_start_command" "pass"
	else
		write_result "${RESULT_FILE}" "postgresql_start_command" "fail"
	fi
	###创建用户、数据库、列表###
	su postgres -c "./psql -c \"create user dbuser1 with password '123456';\""
	if [ $? == 0 ];then
		write_result "${RESULT_FILE}" "postgresql_create_user_command" "pass"
	else
		write_result "${RESULT_FILE}" "postgresql_create_user_command" "fail"
	fi
	su postgres -c "./psql -c \"create database db1 owner dbuser1;\""
	if [ $? == 0 ];then
		write_result "${RESULT_FILE}" "postgresql_create_database_command" "pass"
	else
		write_result "${RESULT_FILE}" "postgresql_create_database_command" "fail"
	fi
	su postgres -c "./psql -c \"\l\" | grep db1"
	if [ $? == 0 ];then
		write_result "${RESULT_FILE}" "postgresql_select_database_command" "pass"
	else
		write_result "${RESULT_FILE}" "postgresql_select_database_command" "fail"
	fi
	su postgres -c "./psql -U dbuser1 -d db1 -c \"create table abc(ID varchar(50),name varchar(50),age varchar(50),adress varchar(50),salary varchar(50));\""
	if [ $? == 0 ];then
		write_result "${RESULT_FILE}" "postgresql_create_table_command" "pass"
	else
		write_result "${RESULT_FILE}" "postgresql_create_table_command" "fail"
	fi
	su postgres -c "./psql -U dbuser1 -d db1 -c \"\d\" | grep abc"
	if [ $? == 0 ];then
		write_result "${RESULT_FILE}" "postgresql_select_table_command" "pass"
	else
		write_result "${RESULT_FILE}" "postgresql_select_table_command" "fail"
	fi
	###对表进行数据更改###
	su postgres -c "./psql -U dbuser1 -d db1 -c \"insert into abc(ID,name,age)values('1','zhang','15');\""
	if [ $? == 0 ];then
		write_result "${RESULT_FILE}" "postgresql_insert_data_command" "pass"
	else
		write_result "${RESULT_FILE}" "postgresql_insert_data_command" "fail"
	fi
	su postgres -c "./psql -U dbuser1 -d db1 -c \"select * from abc;\"|grep zhang"
	if [ $? == 0 ];then
		write_result "${RESULT_FILE}" "postgresql_select_data_command" "pass"
	else
		write_result "${RESULT_FILE}" "postgresql_select_data_command" "fail"
	fi
	su postgres -c "./psql -U dbuser1 -d db1 -c \"update abc set name='wang' where name='zhang';\""
	if [ $? == 0 ];then
		write_result "${RESULT_FILE}" "postgresql_modify_data_command" "pass"
	else
		write_result "${RESULT_FILE}" "postgresql_modify_data_command" "fail"
	fi		
}

################################基本功能测试################################
###基本功能测试###
function basic_function()
{  
	###@test1###
	test1
}

################################压力测试################################
function performance_test()
{
	###@数据导入 @数据导出 @压力测试###   
	cd /root/test-definitions/auto-test/middleware/database/postgresql/postgresql-9.2.23/contrib/pgbench
	make && make install
	cd /usr/local/pgsql/bin
	./pgbench -i -F 100 -s 714 -h 127.0.0.1 -p 5432 -U dbuser1 db1 #10GB dataset
	if [ $? == 0 ];then
		write_result "${RESULT_FILE}" "postgresql_import_data_command" "pass"
	else
		write_result "${RESULT_FILE}" "postgresql_import_data_command" "fail"
	fi
	touch /home/123.txt
	./pg_dump -U dbuser1 db1 -t abc > /home/123.txt
	if [ $? == 0 ];then
		write_result "${RESULT_FILE}" "postgresql_outport_data_command" "pass"
	else
		write_result "${RESULT_FILE}" "postgresql_outport_data_command" "fail"
	fi
	./pgbench -M prepared -r -c 8 -j 2 -T 10 -n -U dbuser1 -p 5432 -d db1
	if [ $? == 0 ];then
		write_result "${RESULT_FILE}" "postgresql_pressure_test_command" "pass"
	else
		write_result "${RESULT_FILE}" "postgresql_pressure_test_command" "fail"
	fi
}

################################清理环境################################
function clean_env()
{
	###@清除临时文件###
	#FUNC_CLEAN_TMP_FILE
	
	###@卸载APP###
	ps -ef|grep "postgres -D"|grep -v grep|awk '{print $2}'|xargs kill -9		
	#${INSTALL_DIR}/${INSTALL_SCRIPT} unistall
	rm -rf ${path}/postgresql-9.2.23 ${path}/postgresql-9.2.23.tar.gz
	rm -rf /usr/local/pgsql
}

################################调用所有函数################################
function main()
{
	###@调用所有的函数###
	check_release
	init_env
	basic_function
	performance_test
	
	###@清理环境###
	clean_env 

	###@检查结果文件###
	check_resultes ${RESULT_FILE}
	
	###@结果文件转为json文件，方便入库###
	cd ${path}
	python ${PY_JSON_TRANSFOR} ${RESULT_FILE} ${test_name}
	add_json ${test_name}.json
	
	###@调用入库函数###
	#data_to_db ${PWD}/${test_name}.json
	rm -rf ${RESULT_FILE}
	echo "case test Complete"
}

main