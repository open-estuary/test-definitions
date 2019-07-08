#!/bin/bash

############################################################################
#用例名称：pmqtest_function
#用例功能：
#       1.测试POSIX消息队列的进程间通信延迟
#作者:  何军健 hwx573498
#完成时间:  2019/05/13
#版本号:    V0.1
##############################################################################

################################初始化变量################################
set -x
LOOPS="1000" # #pmqtest -l 在POSIX消息队列进程间循环1000次通信
path=`pwd` #当前脚本路径
INSTALL_DIR=../../../../../estuary-app/app_install_scripts #指定安装脚本所在目录
INSTALL_SCRIPT=${INSTALL_DIR}/rt-test.sh #指定安装脚本
PY_JSON_TRANSFOR=../../../../utils/result_transfor_json.py #将测试结果转为json的python脚本

################################导入公共函数################################
PUBLIC_UTILS_DIR=../../../../utils
. ${PUBLIC_UTILS_DIR}/sys_info.sh
. ${PUBLIC_UTILS_DIR}/sh-test-lib
. ${PUBLIC_UTILS_DIR}/test_case_common.inc

################################发行版检测################################
function check_release()
{ 
    ###@检测发行版### 
    cat /etc/os-release
    uname -a
    dmidecode --type processor | grep Version
}

################################获取脚本名称作为测试用例名称################################
test_name=$(basename $0 | sed -e 's/\.sh//')

################################@创建log目录################################
TMPDIR=${path}/logs
mkdir -p ${TMPDIR}

################################存放脚本处理中间状态/值等################################
TMPFILE=${TMPDIR}/${test_name}.tmp

################################存放每个测试步骤的执行结果################################
RESULT_FILE=${TMPDIR}/${test_name}_rst.log

################################初始化环境包含（安装所需要的包）################################
function init_env()
{ 
    ###@调用安装脚本###
    chmod +x ${INSTALL_SCRIPT}
    ###@调用安装脚本###
    ${INSTALL_SCRIPT}
    ###@检查结果文件是否存在，创建结果文件###
    check_resultfile ${RESULT_FILE}
    cd rt-tests-1.0
}

################################测试函数实现区域################################
#以SMP模式运行进行1000次循环测试
function pmqtest_run(){
    ./pmqtest -S -l "${LOOPS}" | tee ${TMPFILE}
    #提取日志文件
    #查看最后一个进程程的最小延迟
    min_latency=`tail -n 1 ${TMPFILE}| sed 's/,//g'| awk '{print($(NF-6))};'`
    #查看最后一个进程程的平均延迟
    avg_latency=`tail -n 1 ${TMPFILE}| sed 's/,//g'| awk '{printf($(NF-2))};'`
    #查看最后一个进程程的最大延迟
    max_latency=`tail -n 1 ${TMPFILE}| sed 's/,//g'| awk '{printf($NF)};'`
    if [ ${min_latency} -ne 0 -a ${avg_latency} -ne 0 -a ${max_latency} -ne 0 ];then
        ###@把测试的结果写入到结果文件中###
        write_result "${RESULT_FILE}" "pmqtest" "pass"
    else
        write_result "${RESULT_FILE}" "pmqtest" "fail"
    fi

}

################################基本功能测试################################
###基本功能测试###
function basic_function()
{  
    ###@#运行pqmtest##
    pmqtest_run
}

################################清理环境################################
function clean_env()
{
    ###@卸载APP###
    cd -
    ${INSTALL_SCRIPT} uninstall
}

###调用所有函数###
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
    rm -rf ${RESULT_FILE} logs
    echo "case test Complete"
}

main 


