#!/bin/bash
############################################################################
#用例名称：mongodb_function
#用例功能：
#        1.编译安装gcc7.2和mongodb4.0.3
#        2.运行mongodb进行测试
#作者    ：何军健 hwx573498
#完成时间：2019/05/30
#版本号  ： V0.1
##############################################################################

################################初始化变量################################
set -x
path=`pwd` #当前脚本路径
TEST_RESULT_LOG="mongodb_result.txt" #mongodb测试结果文件
INSTALL_DIR=../../../../../estuary-app/app_install_scripts #指定安装脚本所在目录
INSTALL_SCRIPT=${INSTALL_DIR}/mongodb.sh # 指定安装脚本
PY_JSON_TRANSFOR=../../../../utils/result_transfor_json.py # 将测试结果转为json的python脚本

################################导入公共函数################################
PUBLIC_UTILS_DIR=../../../../utils
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
TMPFILE=${TMPDIR}/${test_name}.tmp

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
    ###@检查结果文件是否存在，创建结果文件###
    check_resultfile ${RESULT_FILE}
    chmod +x ${INSTALL_SCRIPT}
    ###@调用安装脚本###
    ${INSTALL_SCRIPT}
    if [ $? -eq 0 ];then
        ###@把测试的结果写入到结果文件中###
        write_result "${RESULT_FILE}" "mongodb_install" "pass"
    else
        write_result "${RESULT_FILE}" "mongodb_install" "fail"
    fi

}

################################测试函数实现区域################################
###@开启mongodb服务端###
function mongodb_start(){
    ## --frok 是可以在后台运行  --dbpath 是mongodb数据存放地方
    lsof -i :27107|grep -v "PID"|awk '{print "kill -9",$2}'|sh
    if [ $? -eq 0 ];then
        echo kill_27107_pass
    else
        echo kill_27107_fail
    fi
    mkdir -p /mongodb/log
    mkdir -p /mongodb/db
    /usr/local/mongo/bin/mongod --fork --dbpath /mongodb/db --logpath /mongodb/log/mongodb.log --logappend
    if [ $? -eq 0 ];then
        ###@把测试的结果写入到结果文件中###
        write_result "${RESULT_FILE}" "mongodb_server_start" "pass"
    else
        write_result "${RESULT_FILE}" "mongodb_server_start" "fail"
    fi
    sleep 2
}

###@运行mongodb服务端进行测试###
function mongodb_client(){
    /usr/local/mongo/bin/mongo test.js 2>& 1|tee -a ${TMPFILE}
    #提取日志文件
    cat ${TMPFILE}|grep "\[js\]"|awk '{print $(NF-2),$NF}' >> ${TEST_RESULT_LOG}
    total_line=`cat ${TEST_RESULT_LOG} |wc -l`
    for line in `seq 1 $total_line`;
    do 
        result_line=`cat ${TEST_RESULT_LOG} | head -n $line | tail -n 1`
        testcase_name1=`echo ${result_line} | awk '{print $1}'`
        testcase_result=`echo ${result_line} | awk '{print $2}'`
        if [ "${testcase_result}"x == "pass"x ];then
            ###@把测试的结果写入到结果文件中###
            write_result "${RESULT_FILE}" "${testcase_name1}" "pass"
        else
            write_result "${RESULT_FILE}" "${testcase_name1}" "fail"
        fi
    done
}

###@#检查mongodb是否正在运行##
function isServerRunning(){
   ps -ef | grep "mongod --fork"| grep -v grep
   if [ $? -eq 0 ];then
        ###@把测试的结果写入到结果文件中###
        write_result "${RESULT_FILE}" "mongodb_server_isRunning" "pass"
   else
        write_result "${RESULT_FILE}" "mongodb_server_isRunning" "fail"
   fi
}

###@#关闭mongodb服务端##
function mongodb_shutdown(){
    ps -ef | grep 'mongod --fork'|grep -v grep
    if [ $? ] ;then
        /usr/local/mongo/bin/mongo <<EOF
        use admin;
        db.shutdownServer();
EOF
    fi
    ps -ef | grep 'mongod --fork'|grep -v grep
    if [ $? -ne 0 ];then
        ###@把测试的结果写入到结果文件中###
        write_result "${RESULT_FILE}" "mongodb_server_shutdown" "pass"
        #rm -rf /usr/lib64/libstdc++.so.6
        #mv /usr/lib64/libstdc++.so.6.7.2 /usr/lib64/libstdc++.so.6
    else
        write_result "${RESULT_FILE}" "mongodb_server_shutdown" "fail"
    fi
}
        

################################基本功能测试################################
###基本功能测试###
function basic_function()
{  

    ###@#运行mongodb##
    mongodb_start
    isServerRunning
    mongodb_client
    mongodb_shutdown

}

################################清理环境################################
function clean_env()
{
    ###@清除临时文件###
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
    lsof -i :27107|grep -v "PID"|awk '{print "kill -9",$2}'|sh
    if [ $? -eq 0 ];then
        echo kill_27107_pass
    else
        echo kill_27107_fail
    fi
    clean_env 
    ###@检查结果文件###
    check_resultes ${RESULT_FILE}
   
    ###@结果文件转为json文件，方便入库###
    python ${PY_JSON_TRANSFOR} ${RESULT_FILE} ${test_name}
	add_json ${test_name}.json
    rm -rf ${RESULT_FILE} ${TEST_RESULT_LOG} logs
    echo "case test Complete"
}

main 


