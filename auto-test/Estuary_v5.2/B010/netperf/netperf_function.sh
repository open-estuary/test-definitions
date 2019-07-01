#!/bin/bash
#用例功能：
#       版本检查：1.14.0
#       http协议接收网络请求
#       https协议接收网络请求
#       图片缩略
#       njs模块解析并处理js请求
#作者：mwx547872
#完成时间：2019/5/22
##############################################################################
path=`pwd`

######初始化变量，新建一些文件######
INSTALL_DIR=${path}/../../../../../estuary-app/app_install_scripts # 指定安装脚本所在目录
INSTALL_SCRIPT=netperf.sh # 指定安装脚本
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

################################存放每个测试步骤的执行结果################################
RESULT_FILE=${TMPDIR}/${test_name}_rst.log

################################初始化环境包含（安装所需要的包）################################
function check_release()
{
    cat /etc/os-release
    uname -a
    dmidecode --type processor |grep Version
}


function init_env()
{
    ###@开启日志入库时间###
    #get_starttime
    ###@调用安装脚本###
    bash ${INSTALL_DIR}/${INSTALL_SCRIPT}

    ###@关闭防火墙
    case $distro in
        centos)
           systemctl stop firewalld.service
           ;;
        debian)
           apt-get install ufw -y
           ufw disable
           ;;
    esac

    ###@检查结果文件是否存在，创建结果文件###
    check_resultfile ${RESULT_FILE}
}


#选择可用端口
function netserver_select()
{
    for ns_port in {12865..13865}
    do
        netstat -alnt|awk '{print $4}'|grep ${ns_port}
        if [ $? -ne 0 ];then
            netserver_port=${ns_port}
            echo "netserver port will use ${netserver_port}"
            break
        else
            continue
        fi
    done
}


#启动netserver
function netserver_start()
{
    netserver -p ${netserver_port}
    netstat -alnt|awk '{print $4}'|grep ${netserver_port}
    if [ $? -eq 0 ];then
        write_result "${RESULT_FILE}" "start-netserver" "pass"
    else
        write_result "${RESULT_FILE}" "start-netserver" "failed"
    fi
}


#基本功能测试
function basic_function()
{
    netserver_select
    netserver_start
    local host_ip="127.0.0.1"
    local test_time=60
    local test_name=("TCP_STREAM" "UDP_STREAM" "TCP_RR" "UDP_RR")
    for test_mode in ${test_name[*]}
    do
        netperf -H ${host_ip} -t ${test_mode} -l ${test_time} -p ${netserver_port} 
        if [ $? -eq 0 ];then
            write_result "${RESULT_FILE}" "netperf-${test_mode}-${test_time}" "pass"
        else
            write_result "${RESULT_FILE}" "netperf-${test_mode}-${test_time}" "failed"
        fi
    done
}


#####清理环境############
function clean_env()
{
    ###@卸载安装包 @结束进程，清理临时文件 @导入测试结果入库结束
    pkill netserver
    netserver_pnum=`ps -ef|grep netserver|wc -l`
    if [ ${netserver_pnum} -gt 1 ];then
        echo "netserver pid kill fail ,please check"
    else
        echo "netserver pid kill success"
    fi
    rm -rf test_result.tmp
    bash ${INSTALL_SCRIPT} uninstall
}


#####调用所有函数############
function main()
{
    ######调用所有的函数
    init_env
    basic_function
    
    #清理环境
    clean_env
	
	###@检查结果文件###
    check_resultes ${RESULT_FILE}
	
    ###@结果文件转为json文件，方便入库###
    cd ${path}
    python ${PY_JSON_TRANSFOR} ${RESULT_FILE} ${test_name}
    add_json ${test_name}.json
	
    ###@清理环境###
    rm -rf ${RESULT_FILE}
    rm -rf ${path}/logs
    echo "case test Complete"
}
main


