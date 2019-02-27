#!/bin/bash

#*****************************************************************************************
# *用例名称：X6000_RTC_001                                                         
# *用例功能：操作系统时间和硬件时间同步                                                 
# *作者：fwx654472                                                                       
# *完成时间：2019-1-21                                                                   
# *前置条件：                                                                            
#   1、OS已配置SOL，连接系统串口                                                                   
# *测试步骤：                                                                               
#	1、OS下查询系统时间和RTC时间
#		a)date
#		b)hwclock -r
#	2、进入OS下设置系统时间，如：
#		a)date -s “08/19/2015 10:00:00”
#		b)date
#		c)hwclock –r
#	3、设置和查询RTC时间：
#		a)hwclock -w
#		b)hwclock –r
#		c)有结果A)    
# 测试结果：                                                                            
#   RTC和系统时间同步测试。                                                         
#*****************************************************************************************

#加载公共函数,具体看环境对应的位置修改
#. ./test_case_common.inc
#. ./error_code.inc
. ../../../../utils/error_code.inc
. ../../../../utils/test_case_common.inc
. ../../../../utils/sys_info.sh
. ../../../../utils/sh-test-lib     

#获取脚本名称作为测试用例名称
test_name=$(basename $0 | sed -e 's/\.sh//')
#创建log目录
TMPDIR=./logs/temp
mkdir -p ${TMPDIR}
#存放脚本处理中间状态/值等
TMPFILE=${TMPDIR}/${test_name}.tmp
#存放每个测试步骤的执行结果
RESULT_FILE=${TMPDIR}/${test_name}.result

#自定义变量区域（可选）
#var_name1="xxxx"
#var_name2="xxxx"
test_result="pass"

#设置一个新的时间给操作系统
function set_time()
{
    new_time=$1
    date -s  "${new_time}"
    if [ $? -ne 0 ] 
    then
        PRINT_LOG "WARN" "set time is failure ,please check it "
        return 3
    fi
    PRINT_LOG "INFO" "set time is success."
}

#同步系统时间和硬件时间 
function syn_time()
{
    #获取操作系统时间
    date -s "$1"
    if [ $? -ne 0 ]
    then
        PRINT_LOG "WARN" "exec<date -s>is fail,please check it "
        return 5
    else
        echo "exec date -s is success."
    fi
    
    #同步系统时间给硬件
    hwclock -w
    if [ $? -ne 0 ]
    then
        PRINT_LOG "WARN" "exec hwclock -w is failure ,please check it "
        return 5
    else
        PRINT_LOG "INFO" "exec hwclock -w is success . "
        return 0 
    fi
}

#传入两时间$1,$2，判断是否一致
function time_diff()
{
    time1=$1
    time2=$2
    time_seconds=$(( ${time1} - ${time2} ))
    if ((${time_seconds}<=0))
    then
        time_seconds=$((-${time_seconds}))
    fi
    #由于保存时间大概消耗3秒，以3秒为整数
    diff_value=$(( ${time_seconds} / 3 ))
    if [ ${diff_value} -eq 0 ]
    then
        PRINT_LOG "INFO" "time is equal"
        return 0
    else
        PRINT_LOG "WARN" "time is diff"
        return 1
    fi
}


#预置条件
function init_env()
{
    #检查结果文件是否存在，创建结果文件：
    fn_checkResultFile ${RESULT_FILE}
    
    #root用户执行
    if [ `whoami` != 'root' ]
    then
        PRINT_LOG "WARN" " You must be root user " 
        return 1
    fi
    
    #自定义测试预置条件检查实现部分：比如工具安装，检查多机互联情况，执行用户身份 
      #需要安装工具，使用公共函数install_deps，用法：install_deps "${pkgs}"
      #需要日志打印，使用公共函数PRINT_LOG，用法：PRINT_LOG "INFO|WARN|FATAL" "xxx"
}

#测试执行
function test_case()
{
    #测试步骤实现部分
    #查看当前系统时间和硬件时间是否一致
    #获取系统时间
    date_value=`date +"%Y-%m-%d %H:%M:%S"` 
    if [ $? -ne 0 ]
    then
        PRINT_LOG "FATAL" "Can not get time from OS system,please check it"
        return 2
    fi
    
    sys_seconds=$(date +%s -d "${date_value}")
    if [ $? -ne 0 ]
    then
        PRINT_LOG "FATAL" "Can not get hwclock time,please check it"
        return 2
    fi
    
    #获取硬件时间
    hwclock_value=`hwclock -r`
    hw_seconds=$(date +%s -d "${hwclock_value}")

    #如果已经同步，则需要修改为不同步再测试 
    #如果不同，则直接运行测试
    time_diff ${sys_seconds} ${hw_seconds}
    if [ $? -ne 0 ]
    then
        sys_time=`date +"%Y-%m-%d %H:%M:%S"`
        sys_seconds=$(date +%s -d "${sys_time}")
        syn_time "${sys_time}"
        
        hw_time=`hwclock -r`
        hw_seconds=$(date +%s -d "${hw_time}")
        
        time_diff ${sys_seconds} ${hw_seconds}
        if [ $? -ne 0 ]
        then
            PRINT_LOG "WARN" "hwclock and system date can not synchronous"
            return 1
        fi
        PRINT_LOG "INFO" "hwclock and system date is synchronous,test rusualt is OK."
        return 0
    else
        #给个任意时间
        new_time="08/19/2015 10:00:00"
        #sleep 10
        
        set_time ${new_time} || return 2
        
        sys_time=`date +"%Y-%m-%d %H:%M:%S"`
        sys_seconds=$(date +%s -d "${sys_time}")
        
        syn_time "${sys_time}"
        
        #hw_time=$(date +%s -d "${hwclock_value}")
        hwclock_value=`hwclock -r`
        hw_seconds=$(date +%s -d "${hwclock_value}")
        time_diff ${sys_seconds} ${hw_seconds}
        if [ $? -ne 0 ]
        then
            PRINT_LOG "FATAL" "hwclock and system date can not synchronous"
            fn_writeResultFile "${RESULT_FILE}" "test_sync_name" "fail"
            return 1
        fi
        PRINT_LOG "INFO" "hwclock and system date is synchronous,test rusualt is OK."
        fn_writeResultFile "${RESULT_FILE}" "test_sync_name" "pass"
        return 0        
    fi
    #检查结果文件，根据测试选项结果，有一项为fail则修改test_result值为fail，
    check_result ${RESULT_FILE}
}

#恢复环境
function clean_env()
{
    #清除临时文件
    FUNC_CLEAN_TMP_FILE
    #自定义环境恢复实现部分,工具安装不建议恢复
      #需要日志打印，使用公共函数PRINT_LOG，用法：PRINT_LOG "INFO|WARN|FATAL" "xxx"

}


function main()
{
    init_env || test_result="fail"
    if [ ${test_result} = 'pass' ]
    then
        test_case || test_result="fail"
    fi
    clean_env || test_result="fail"
}

main $@
ret=$?
#LAVA平台上报结果接口，勿修改
lava-test-case "$test_name" --result ${test_result}
exit ${ret}
