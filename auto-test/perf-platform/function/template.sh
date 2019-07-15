#!/bin/bash

############################################################################
#用例名称：templator
#用例功能：
#    1. 提供用例编写规范
#    2. 其它
#作者    ：苏周 swx562878
#完成时间：2019/05/28
#版本号  ： V0.1
##############################################################################

################################初始化变量################################
INSTALL_DIR=./ # 指定安装脚本所在目录
INSTALL_SCRIPT=xxx_install.sh # 指定安装脚本
PY_JSON_TRANSFOR=../../../../utils/result_transfor_json.py # 将测试结果转为json的python脚本

################################导入公共函数################################
PUBLIC_UTILS_DIR=../../../../utils
. ${PUBLIC_UTILS_DIR}/sys_info.sh
. ${PUBLIC_UTILS_DIR}/sh-test-lib
. ${PUBLIC_UTILS_DIR}/test_case_common.inc

################################获取脚本名称作为测试用例名称################################
test_name=$(basename $0 | sed -e 's/\.sh//')

################################@创建log目录################################
TMPDIR=./logs
mkdir -p ${TMPDIR}

################################存放脚本处理中间状态/值等################################
#!!!!!!!!可否不使用中间状态文件,直接用字符串存储中间数据!!!!!!!!!!!
#TMPFILE=${TMPDIR}/${test_name}.tmp

################################存放每个测试步骤的执行结果################################
RESULT_FILE=${TMPDIR}/${test_name}_rst.log

################################初始化环境包含（安装所需要的包）################################
function init_env()
{ 
    ###@开启日志入库时间### 
    get_starttime
	
	###@调用安装脚本###
	${INSTALL_DIR}/${INSTALL_SCRIPT}
	
    ###@检查结果文件是否存在，创建结果文件###
    check_resultfile ${RESULT_FILE}
	if [ -f ${RESULT_FILE}];then
		echo "create file is pass"
	else
		echo "create file is fail"
		exit 1
	fi
}

################################测试函数实现区域################################
###@test1###
function test1()
{	
	###例如###
    res0=`redis-cli ZADD sortkey 1  "one"  2 "shell"`
    if [ $res0 -eq 2 ];then
	    ###@把测试的结果写入到结果文件中###
        write_result "${RESULT_FILE}" "redis_ZADD_command" "pass"
    else
        write_result "${RESULT_FILE}" "redis_ZADD_command" "fail"
    fi
}

###@test2###
function test2()
{
	###例如###
    res0=`redis-cli ZADD sortkey 1  "one"  2 "shell"`
    if [ $res0 -eq 2 ];then
	    ###@把测试的结果写入到结果文件中
        write_result "${RESULT_FILE}" "redis_ZADD_command" "pass"
    else
        write_result "${RESULT_FILE}" "redis_ZADD_command" "fail"
    fi
}

################################基本功能测试################################
###基本功能测试###
function basic_function()
{  
	###@test1###
    test1
	
    ###@test2###
    test2
}

###压力测试###
function performance_test()
{
	###@压力测试###
	res0=`redis-cli ZADD sortkey 1  "one"  2 "shell"`
    if [ $res0 -eq 2 ];then
		###@把测试的结果写入到结果文件中###
        write_result "${RESULT_FILE}" "redis_ZADD_command" "pass"
    else
        write_result "${RESULT_FILE}" "redis_ZADD_command" "fail"
    fi
}

################################清理环境################################
function clean_env()
{
    ###@清除临时文件###
    FUNC_CLEAN_TMP_FILE
	
    ###@停止服务 @结束进程 @移除redis###
	#    1）pkill -9  需判断是否kill掉进程
	#    2）systemctl  查看状态，判断是否关闭
	#    3）其它
}

###调用所有函数###
function main()
{
	###@调用所有的函数###
	init_env 
    basic_function
    performance_test
	
	###@检查结果文件###
    check_result ${RESULT_FILE}
	
	###@结果文件转为json文件，方便入库###
    python ${PY_JSON_TRANSFOR} ${RESULT_FILE} ${test_name}
	
	###@调用入库函数###
	#data_to_db ${PWD}/${test_name}.json #!!!!!!!!需要处理失败异常!!!!!!!!!!!
	
	###@清理环境###
    clean_env 
	
	echo "case test Complete"
}

main 


