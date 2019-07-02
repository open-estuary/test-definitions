#!/bin/bash

############################################################################
#用例名称:$pi-stress_function.sh
#用例功能：
#验证pi_stress可否实现优先级继承互斥压力测试
#作者：swx703520
#完成时间：2019/5/11
#版本号  ：V0.1
##############################################################################

################################发行版检测################################
set -x
function check_release()
{ 
	###@检测发行版### 
	cat /etc/os-release
	uname -a
	dmidecode --type processor | grep Version
}
 
################################初始化变量################################
path=`pwd`
INSTALL_DIR=../../../../../estuary-app/app_install_scripts #指定安装脚本所在目录
INSTALL_SCRIPT=${INSTALL_DIR}/rt-test.sh # 指定安装脚本
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

################################存放脚本处理中间状态/值等################################
#!!!!!!!!可否不使用中间状态文件,直接用字符串存储中间数据!!!!!!!!!!!
#TMPFILE=${TMPDIR}/${test_name}.tmp

################################存放每个测试步骤的执行结果################################
RESULT_FILE=${TMPDIR}/${test_name}_rst.log

################################初始化环境包含（安装所需要的包）################################
function init_env()
{ 
    ###@开启日志入库时间### 
#   get_starttime
	chmod +x ${INSTALL_SCRIPT}
	###@调用安装脚本###
	${INSTALL_SCRIPT}
	
    ###@检查结果文件是否存在，创建结果文件###
	check_resultfile ${RESULT_FILE}
    cd rt-tests-1.0
}

################################测试函数实现区域################################
###@test1###
function test1()
{
#####验证pi_stress可否实现优先级继承互斥压力测试#####
	./pi_stress --duration 10 
	if [ $? -eq 0 ];then
	    ###@把测试的结果写入到结果文件中###
        write_result "${RESULT_FILE}" "pi_command" "pass"
    else
        write_result "${RESULT_FILE}" "pi_command" "fail"
    fi
}

################################基本功能测试################################
###基本功能测试###
function basic_function()
{
	test1
}


################################清理环境################################
function clean_env()
{
    cd -
  ###@清除临时文件###
    ${INSTALL_SCRIPT} uninstall
}

function main()
{
	###@调用所有的函数###
	check_release
	init_env 
  	basic_function
	###@清理环境###
    clean_env
	###@检查结果文件###
    check_result ${RESULT_FILE}

	###@结果文件转为json文件，方便入库###
    python ${PY_JSON_TRANSFOR} ${RESULT_FILE} ${test_name}
	add_json ${test_name}.json
	###@调用入库函数###
	#data_to_db ${PWD}/${test_name}.json 
    rm -rf ${RESULT_FILE}
	echo -e "\033[32m case test Complete \033[0m"
}

main 
