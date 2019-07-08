#!/bin/bash
############################################################################
#用例名称：hackbench_function
#用例功能：
#       1.测试linux调度器的延迟时间
#作者   ：何军健 hwx573498
#完成时间：2019/05/13
#版本号： V0.1
##############################################################################

################################初始化变量################################
set -x
path=`pwd` #当前脚本路径
DATASIZE="100" #hackbenck -d 数据通信发送的数据大小
LOOPS="100" #hackbench -l 数据通信收发消息的循环次数
GRPS="10" #hackbench -g 启动发送方和接收方的组数
FDS="20" #hackbech -f 打开文件描述符的个数
TEST_LOG="output-" #hackbenc运行的日志文件名称
OPTS="-s ${DATASIZE} -l ${LOOPS} -g ${GRPS} -f ${FDS}" #hackbench基本参数选项字符串
INSTALL_DIR=../../../../../estuary-app/app_install_scripts # 指定安装脚本所在目录
INSTALL_SCRIPT=${INSTALL_DIR}/rt-test.sh # 指定安装脚本
PY_JSON_TRANSFOR=../../../../utils/result_transfor_json.py # 将测试结果转为json的python脚本
#hackbench测试结果输出的测试点名称
HACKBENCH_TAG=("hackbench_process_pipe" "hackbench_process_socket" "hackbench_thread_pipe" "hackbench_thread_socket")

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
TMPDIR=${PATH}/logs
mkdir -p ${TMPDIR}

################################存放脚本处理中间状态/值等################################
#TMPFILE=${TMPDIR}/${test_name}.tmp

################################存放每个测试步骤的执行结果################################
RESULT_FILE=${TMPDIR}/${test_name}_rst.log

################################初始化环境包含（安装所需要的包）################################
function init_env()
{ 
    ###@调用安装脚本###
    chmod +x ${INSTALL_SCRIPT}
    ${INSTALL_SCRIPT}
    ###@检查结果文件是否存在，创建结果文件###
    check_resultfile ${RESULT_FILE}
    cd rt-tests-1.0
}

################################测试函数实现区域################################

#循环4次运行hackbench 根据传入的$1参数指定hackbench的参数选项来运行
function run_hackbench()
{
    #根据传入的$2值确定是第几次运行的,然后从HACKBENCH_TAG列表中获取相应的hackbench参数选项
    let s=$2-1
    #根据s值确定HACKBENCH_TAG的值,从而得到每次hackbench运行的参数选项值
    hackbench_tag=${HACKBENCH_TAG[${s}]}
    #执行hackbench测试中输出的日志写入到日志文件中
    ./hackbench "$1" 2>&1 | tee -a "${TEST_LOG}${hackbench_tag}.log"
    grep "^Time" "${TEST_LOG}${hackbench_tag}.log"
    if [ $? -eq 0 ];then
        ###@把测试的结果写入到结果文件中
        write_result "${RESULT_FILE}" "${hackbench_tag}" "pass"
    else
        write_result "${RESULT_FILE}" "${hackbench_tag}" "fail"
    fi

}

################################基本功能测试################################
###基本功能测试###
function basic_function()
{ 
    for i in $(seq 4); do
        case "${i}" in
            1)#以进程模式pipe数据通信方式运行hackbench
                #第1次以hackbench-P-p("-p"管道数据通信,"-P"进程模式)运行
                run_hackbench "${OPTS} -P -p" "$i"
            ;;
            2) #以进程模式socket数据通信方式运行hackbench
                #第2次以hackbench-P(默认以socket数据通信方式"-s"socket数据通信,"-P"进程模式)运行
                run_hackbench "${OPTS} -P" "$i"
            ;;
            3)#以线程模式pipe数据通信方式运行hackbench
                #第3次以hackbench-T-p("-p"管道数据通信,"-T"线程模式)运行
                run_hackbench "${OPTS} -T -p" "$i"
            ;; 
            4)#以线程模式socket数据通信方式运行hackbench
                #第4次以hackbench-T(默认以socket数据通信方式"-s"socket数据通信,"-T"线程模式)运行
                run_hackbench "${OPTS} -T" "$i"
           ;; 
        esac 
    done
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
    rm -rf ${RESULT_FILE} output-* logs
    echo "case test Complete"
}

main 



