#!/bin/bash
set -x

############################################################################
#用例名称：redis
#用例功能：
#	基本功能测试
#	压力测试
#作者：swx562878
#完成时间：2019/5/15
##############################################################################

set -x
path=`pwd`
################################初始化变量################################
INSTALL_DIR=${path}/../../../../../estuary-app/app_install_scripts # 指定安装脚本所在目录
INSTALL_SCRIPT=redis.sh # 指定安装脚本
PY_JSON_TRANSFOR=../../../../utils/result_transfor_json.py # 将测试结果转为json的python脚本


################################导入公共函数################################
PUBLIC_UTILS_DIR=../../../../utils
. ${PUBLIC_UTILS_DIR}/sys_info.sh
. ${PUBLIC_UTILS_DIR}/sh-test-lib
. ${PUBLIC_UTILS_DIR}/test_case_common.inc

################################获取脚本名称作为测试用例名称################################
test_name=$(basename $0 | sed -e 's/\.sh//')

################################@创建log目录################################
TMPDIR=${path}/logs
mkdir -p ${TMPDIR}

################################存放每个测试步骤的执行结果################################
RESULT_FILE=${TMPDIR}/${test_name}_rst.log

################################发行版检测################################
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
	
	###@调用安装脚本###
	bash ${INSTALL_DIR}/${INSTALL_SCRIPT}
	
	###@检查结果文件是否存在，创建结果文件###
	check_resultfile ${RESULT_FILE}
}


################################测试函数实现区域################################
####redis服务的启动
function redis_start()
{
	port=$1
	if [ -z $port ];then
			port="6379"
	fi

	ps -ef | grep "redis-server.*${port}" | grep -v grep
	if [ $? -eq 0 ];then
		echo "redis_server_is_running"
	fi
	
	CONF=/usr/local/redis-4.0.2/redis.conf
	
	mkdir -p /redis/db/$port
	cp -f $CONF /redis/db/$port
	#修改配置文件，可以后台运行
	sed -i 's/daemonize no/daemonize yes/' /redis/db/${port}/redis.conf
	grep "daemonize yes" /redis/db/${port}/redis.conf


	process=`ps -ef |grep redis |grep server |awk '{print $2}'`
	for i in ${process}
	do
		kill -9 $i
	done
	file="/redis/db/${port}/redis.conf"
	taskset -c 1 redis-server $file --port $port
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis_started"  "pass"
	else
		write_result "${RESULT_FILE}" "redis_started"  "fail"
	fi

}


####redis_auth 命令的使用####
function redis_auth()
{
	res=`redis-cli CONFIG set requirepass 123`
	if [ $res == "OK"  ];then
		write_result "${RESULT_FILE}" "redis_set_password" "pass"
	else
		write_result "${RESULT_FILE}" "redis_set_password" "fail"
	fi
	
	res1=`redis-cli -a 123 CONFIG get requirepass`
	echo $res1 | grep "error"
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis_login_use_password" "fail" 
	else
		write_result "${RESULT_FILE}" "redis_login_use_password" "pass" 
	fi
	
	res3=`redis-cli -a 123 CONFIG set requirepass ""`
	if [ $res == "OK"  ];then
		write_result "${RESULT_FILE}" "redis_cancle_password" "pass"
	else
		write_result "${RESULT_FILE}" "redis_cancle_password" "fail"
	fi
}


###@redis-string（字符串）类型命令测试####
function redis_string()
{
	res=`redis-cli ping`
	if [ $res == "PONG"  ];then
		write_result "${RESULT_FILE}" "redis_string_ping_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_string_ping_command" "fail"
	fi

	res0=`redis-cli flushall`
	if [ $res0 == "OK" ];then
		write_result "${RESULT_FILE}" "redis_string_flushall_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_string_flushall_command" "fail"
	fi

	res1=`redis-cli set redis redis`
	if [ $res1 == "OK"  ];then
		write_result "${RESULT_FILE}" "redis_string_set_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_string_set_command" "fail"
	fi
	
	res2=`redis-cli exists redis`
	if [ $res2 == 1  ];then
		write_result "${RESULT_FILE}" "redis_string_exists_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_string_exists_command" "fail"
	fi

	res3=`redis-cli get redis`
	if [ $res3=="redis" ] ;then
		write_result "${RESULT_FILE}" "redis_string_get_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_string_get_command" "fail"
	fi

	res4=`redis-cli getrange redis 1 2`
	if [ $res4 == "ed" ];then
		write_result "${RESULT_FILE}" "redis_string_getrange_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_string_getrange_command" "fail"
	fi

	redis-cli getset redis database
	res5=`redis-cli get redis`
	if [ $res5 = "database"  ];then
		write_result "${RESULT_FILE}" "redis_string_getset_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_string_getset_command" "fail"
	fi

	redis-cli set estuary root
	res6=`redis-cli mget estuary redis`
	echo $res6 | grep database && echo $res6 | grep root
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis_string_mget_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_string_mget_command" "fail"
	fi

	res7=`redis-cli setnx redis redis`
	res8=`redis-cli setnx book book`
	if [[  $res7 == 0 && $res8 == 1  ]];then
		write_result "${RESULT_FILE}" "redis_string_setnx_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_string_setnx_command" "fail"
	fi

	redis-cli set num 10
	redis-cli incr num
	res9=`redis-cli get num`
	if [ $res9 == 11  ];then
		write_result "${RESULT_FILE}" "redis_string_incr_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_string_incr_command" "fail"
	fi
	
	res10=`redis-cli decr num`
	if [ $res10 == 10 ];then
		write_result "${RESULT_FILE}" "redis_string_decr_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_string_decr_command" "fail"
	fi

	redis-cli set redis aa
	res11=`redis-cli strlen redis`
	if [ $res11 == 2  ];then
		write_result "${RESULT_FILE}" "redis_string_strlen_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_string_strlen_command" "fail"
	fi

	res12=`redis-cli exists redis`
	res13=`redis-cli append redis estuary`
	if [[  $res12 == 1 && $res13 == 9  ]] || [[ $res12 == 0 && $res13 == 7 ]];then
		write_result "${RESULT_FILE}" "redis_string_append_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_string_append_command" "fail"
	fi
}


####redis-hash（散列）类型命令的测试####
function redis_hash()
{
	redis-cli HMSET myhash field1 "hello" field2 "world"
	redis-cli hmget myhash field1 field2 2>&1|tee -a ${path}/2.txt
	cat ${path}/2.txt |grep hello && cat ${path}/2.txt|grep world
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis_hash_Hmget_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_hash_Hmget_command" "fail"
	fi
	

	res1=`redis-cli HGET myhash field1`
	if [ $res1 == "hello" ];then
		write_result "${RESULT_FILE}" "redis_hash_hget_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_hash_hget_command" "fail"
	fi

	res2=`redis-cli hexists myhash field2`
	if [ $res2 == 1 ];then
		write_result "${RESULT_FILE}" "redis_hash_hexists_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_hash_hexists_command" "fail"
	fi

	res3=`redis-cli hkeys myhash`
	echo $res3 | grep "field1"  && echo $res3 | grep "field2"
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis_hash_HKEYS_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_hash_HKEYS_command" "fail"
	fi

	res4=`redis-cli hvals myhash`
	echo $res4 | grep "hello" && echo $res4 | grep "world"
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis_hash_HVALS_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_hash_HVALS_command" "fail"
	fi
	
	res5=`redis-cli hdel myhash field2`
	if [ $res5 == 1  ];then
		write_result "${RESULT_FILE}" "redis_hash_hdel_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_hash_hdel_command" "fail"
	fi

	res6=`redis-cli HSETNX myhash field2 "ADD"`
	if [ $res6 == 1  ];then
		write_result "${RESULT_FILE}" "redis_hash_hsetnx_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_hash_hsetnx_command" "fail"
	fi
}


####redis_list（列表）类型命令的测试####
function redis_list()
{
	res0=`redis-cli LPUSH rediskey redis`
	if [ $res0 -ge 1 ];then
		write_result "${RESULT_FILE}" "redis_list_LPUSH_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_list_LPUSH_command" "fail"
	fi
	
	redis-cli LPUSH rediskey mongodb
	res1=`redis-cli LRANGE rediskey 0 -1`
	echo $res1 | grep "mongodb redis"
	if [ $?  -eq 0 ];then
		write_result "${RESULT_FILE}" "redis_list_LRANGE_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_list_LRANGE_command" "fail"
	fi

	res2=`redis-cli RPUSH rediskey mysql`
	if [ $res2 == 3 ];then
		write_result "${RESULT_FILE}" "redis_list_RPUSH_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_list_RPUSH_command" "fail"
	fi

	res3=`redis-cli LINDEX rediskey -1`
	if [ $res3 == "mysql" ];then
		write_result "${RESULT_FILE}" "redis_list_LINDEX_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_list_LINDEX_command" "fail"
	fi

	redis-cli RPUSHX rediskey postgresql
	res4=`redis-cli RPUSHX rediskeyx postgresql`
	res5=`redis-cli LINDEX rediskey -1`
	if [[  $res4 == 0 &&  $res5 == "postgresql" ]];then
		write_result "${RESULT_FILE}" "redis_list_RPUSHX_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_list_RPUSHX_command" "fail"
	fi

	res6=`redis-cli LLEN rediskey`
	if [ $res6 == 4 ];then
		write_result "${RESULT_FILE}" "redis_list_LLEN_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_list_LLEN_command" "fail"
	fi

	res7=`redis-cli LPOP rediskey`
	if [ $res7 == "mongodb" ];then
		write_result "${RESULT_FILE}" "redis_list_LPOP_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_list_LPOP_command" "fail"
	fi

	res8=`redis-cli RPOP rediskey`
	if [ $res8 == "postgresql" ];then
		write_result "${RESULT_FILE}" "redis_list_RPOP_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_list_RPOP_command" "fail"
	fi
}


####redis_set（集合）类型命令的测试####
function redis_set()
{
	res1=`redis-cli SADD redisset redis`
	if [ $res1 == 1  ];then
		write_result "${RESULT_FILE}" "redis_set_SADD_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_set_SADD_command" "fail"
	fi

	res2=`redis-cli SISMEMBER redisset redis`
	if [ $res2 == 1  ];then
		write_result "${RESULT_FILE}" "redis_set_SISMEMBER_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_set_SISMEMBER_command" "fail"
	fi
	redis-cli SADD redisset mysql
	redis-cli SADD redisset mongodb 
	redis-cli SADD redisset2 redis mysql postgresql 

	res3=`redis-cli SCARD redisset`
	res4=`redis-cli SCARD redisset3`
	if [[ $res3 == 3 && $res4 == 0   ]];then
		write_result "${RESULT_FILE}" "redis_set_SCARD_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_set_SCARD_command" "fail"
	fi

	res5=`redis-cli SDIFF redisset redisset2`
	if [ $res5 == "mongodb" ];then
		write_result "${RESULT_FILE}" "redis_set_SDIFF_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_set_SDIFF_command" "fail"
	fi

	res6=`redis-cli SINTER redisset redisset2`
	echo $res6 | grep redis && echo $res6 | grep mysql 
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis_set_SINTER_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_set_SINTER_command" "fail"
	fi

	res7=`redis-cli SUNION redisset redisset2`
	echo $res7 | grep redis && echo $res7 | grep postgresql
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis_set_SUNION_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_set_SUNION_command" "fail"
	fi

	res8=`redis-cli SREM redisset redis`
	if [ $res8 -eq 1 ];then
		write_result "${RESULT_FILE}" "redis_set_SREM_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_set_SREM_command" "fail"
	fi

	res9=`redis-cli SMOVE redisset redisset2 "mongodb"`
	if [ $res9 -eq 1 ];then
		write_result "${RESULT_FILE}" "redis_set_SMOVE_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_set_SMOVE_command" "fail"
	fi
}


####redis_sortedset（sorted set有序集合）类型命令的测试####
function redis_sortedset()
{
	res0=`redis-cli ZADD sortkey 1  "one"  2 "shell"`
	if [ $res0 -eq 2 ];then
		write_result "${RESULT_FILE}" "redis_sortedset_ZADD_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_sortedset_ZADD_command" "fail"
	fi
	
	res1=`redis-cli ZCARD sortkey `
	if [ $res1 -eq 2 ];then
		write_result "${RESULT_FILE}" "redis_sortedset_ZCARD_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_sortedset_ZCARD_command" "fail"
	fi

	res2=`redis-cli ZRANGEBYLEX sortkey - [shell `
	echo $res2 | grep one && echo $res2 | grep shell
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis_sortedset_ZRANGEBYLEX_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_sortedset_ZRANGEBYLEX_command" "fail"
	fi

	res3=`redis-cli Zrem sortkey one `
	if [ $res3 -eq 1 ];then
		write_result "${RESULT_FILE}" "redis_sortedset_Zrem_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_sortedset_Zrem_command" "fail"
	fi
}


####redis_save的命令####
function redis_save()
{
	res=`redis-cli set save isSave`
	res2=`redis-cli save`
	if [ x"$res2" == x"OK"  ];then
		write_result "${RESULT_FILE}" "redis_sava_database_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_sava_database_command" "fail"
	fi

	res3=`redis-cli CONFIG GET dir`
	path1=`echo $res3 | cut -d " " -f 2`

	mkdir -p /redis/db/7777 

	cp ${path1}/dump.rdb /redis/db/7777/
	redis_start  7777

	res4=`redis-cli -p 7777 GET save`
	if [ x"$res4" == x"isSave"  ];then
		write_result "${RESULT_FILE}" "redis_restore_database_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_restore_database_command" "fail"
	fi
}


####redis_transaction的命令####
function redis_transaction()
{
	cat > ${path}/tmp.txt <<-eof
	MULTI
	FLUSHALL 
	SET bookname "c++" 
	GET bookname
	SADD tag "c++" "mastering series" "programming"
	SISMEMBER tag "c++"
	EXEC
eof
	
	res1=`cat ${path}/tmp.txt | redis-cli`
	echo $res1 | grep "OK OK c++ 3 1"
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis_transaction_exec_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_transaction_exec_command" "fail"
	fi

	cat > ${path}/tmp.txt <<-eof
	MULTI
	FLUSHALL 
	SET bookname "c++" 
	GET bookname
	SADD tag "c++" "mastering series" "programming"
	SISMEMBER tag "c++"
	DISCARD
eof
	res2=`cat ${path}/tmp.txt | redis-cli`
	echo $res2 | grep "^OK.*OK$"
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis_transaction_discard_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis_transaction_discard_command" "fail"
	fi
}


##################redis的基本功能实现（启动redis，测试基本功能）##################
function basic_function()
{
	####@启动redis####
	redis_start
	####@身份验证####
	redis_auth
	####@redis-string（字符串）类型命令测试####
	redis_string
	####redis-hash（散列）类型命令的测试####
	redis_hash
	####redis_list（列表）类型命令的测试####
	redis_list
	####redis_set（集合）类型命令的测试####
	redis_set
	####redis_sortedset（sorted set有序集合）类型命令的测试####
	redis_sortedset
	####redis_transaction的命令####
	redis_transaction
	####redis_save的命令####
	redis_save
}


####使用redis-benchmark进行压力测试######
function performance_test()
{
	####@压力测试
	redis-benchmark -h 127.0.0.1 -p 6379 -c 20 -n 30000 -r 10000 -t get
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis-benchmark-get_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis-benchmark-get_command" "fail"
	fi

	redis-benchmark -h 127.0.0.1 -p 6379 -c 20 -n 30000 -r 10000 -t set
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis-benchmark-set_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis-benchmark-set_command" "fail"
	fi

	redis-benchmark -t ping,set,get -n 100000 --csv
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis-benchmark-ping,set,get_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis-benchmark-ping,set,get_command" "fail"
	fi

	redis-benchmark -r 10000 -n 10000 lpush mylist __rand_int__
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis-benchmark-lpush_mylist_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis-benchmark-lpush_mylist_command" "fail"
	fi

	redis-benchmark -r 10000 -n 10000 eval 'return redis.call("ping")' 0
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "redis-benchmark-eval_command" "pass"
	else
		write_result "${RESULT_FILE}" "redis-benchmark-eval_command" "fail"
	fi
}


#####清理环境############
function clean_env()
{
	#清除临时文件
	echo "${path}  999999999999999999999"
	rm -rf ${path}/2.txt
	rm -rf ${path}/tmp.txt
	rm -rf ${path}/dump.rdb

	###结束进程###
	process=`ps -ef |grep redis |grep server |awk '{print $2}'`
	for i in ${process}
	do
		kill -9 $i
	done
	###卸载###
	bash ${INSTALL_DIR}${INSTALL_SCRIPT} uninstall
}


#####调用所有函数############
function main()
{
	######调用所有的函数
	check_release
	init_env
	basic_function
	redis_start    
	performance_test

	###@清理环境###
	clean_env
	
	###@检查结果文件###
	check_result ${RESULT_FILE}

	###@结果文件转为json文件，方便入库###
	python ${PY_JSON_TRANSFOR} ${RESULT_FILE} ${test_name}
	add_json ${test_name}.json

	###@调用入库函数###
	#data_to_db ${path}/${test_name}.json

	rm -rf ${TMPDIR}
	echo -e "\033[32m case test Complete \033[0m"
}

main
