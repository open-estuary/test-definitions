#!/bin/bash

############################################################################
#用例名称：es
#用例功能：
#    1. 提供用例编写规范
#    2. 其它
#作者    ：刘北洁 lwx588815
#完成时间：2019/05/29
#版本号  ： V0.1
##############################################################################

################################初始化变量################################
INSTALL_DIR=../../../../../estuary-app/app_install_scripts
INSTALL_SCRIPT=elasticsearch.sh # 指定安装脚本
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
path=`pwd`
TMPDIR=${path}/logs
mkdir -p ${TMPDIR}

################################存放脚本处理中间状态/值等################################
#!!!!!!!!可否不使用中间状态文件,直接用字符串存储中间数据!!!!!!!!!!!
#TMPFILE=${TMPDIR}/${test_name}.tmp

################################存放每个测试步骤的执行结果################################
RESULT_FILE=${TMPDIR}/${test_name}_rst.log

################################发行版检测################################
function check_release()
{ 
    ###@检测发行版### 
	cat /etc/os-release
    	uname -a 
    	dmidecode --type processor |grep Version   
}
################################初始化环境包含（安装所需要的包）################################
function init_env()
{ 
	systemctl stop firewalld
    ###@开启日志入库时间### 
#    	get_starttime
	
	###@调用安装脚本###
	${INSTALL_DIR}/${INSTALL_SCRIPT}
    ###@检查结果文件是否存在，创建结果文件###
        check_resultfile ${RESULT_FILE}
        
}

################################测试函数实现区域################################
###@test1###
function test1()
{	    
	cd ${path}
	adduser ggjj
        passwd ggjj
	if [ ! -d /home/ggjj ];then
		mkdir -p /home/ggjj
	fi
        chown -R ggjj:ggjj /home/elasticsearch-6.2.3
        cd /home/elasticsearch-6.2.3
        su ggjj -c "cd bin && ./elasticsearch -d"
        sleep  60

        curl 'localhost:9200/?pretty'
        if [ $? -eq 0 ];then
                write_result "${RESULT_FILE}" "es_runing" "pass"
        else
                write_result "${RESULT_FILE}" "es_runing" "fail"
        fi

        curl -XPUT 'localhost:9200/my_/my_type/3?pretty' -H 'Content-Type: application/json' -d' { "title":"QUICK!" }'
        if [ $? -eq 0 ];then
                write_result "${RESULT_FILE}" "es_put" "pass"
        else
                write_result "${RESULT_FILE}" "es_put" "fail"
        fi

	curl -X GET "localhost:9200/_search?pretty" -H 'Content-Type: application/json' -d'{"query": { "match_all": {}}}'
        if [ $? -eq 0 ];then
                write_result "${RESULT_FILE}" "es_get_query" "pass"
        else
                write_result "${RESULT_FILE}" "es_get_query" "fail"
        fi

        curl -X GET "localhost:9200/_search?pretty" -H 'Content-Type: application/json' -d'{ "aggs": { "country_population": { "terms": { "field": "country_code"}}}}'
        if [ $? -eq 0 ];then
                write_result "${RESULT_FILE}" "es_get_aggs" "pass"
        else
                write_result "${RESULT_FILE}" "es_get_aggs" "fail"
        fi

        curl -X GET "localhost:9200/_search?pretty" -H 'Content-Type: application/json' -d' { "query": { "term": { "population": 0 }}}'
        if [ $? -eq 0 ];then
                write_result "${RESULT_FILE}" "es_get_term" "pass"
        else
                write_result "${RESULT_FILE}" "es_get_term" "fail"
        fi
}

###@test2###
function test2()
{
	cd ${path}
	bash rally.sh
	cd ${path}
	su ggjj -c "bash rally_runing.sh"
	cd ${path}
	su ggjj -c "/home/ggjj/.local/bin/esrally --track=geonames --target-hosts=localhost:9200 --challenge=append-no-conflicts --pipeline=benchmark-only --report-file=/home/ggjj/data-arm.log"
        if [ $? -eq 0 ];then
                write_result "${RESULT_FILE}" "es_rally" "pass"
        else
                write_result "${RESULT_FILE}" "es_rally" "fail"
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

################################清理环境################################

function clean_env()
{
    ###@清除临时文件###
    #FUNC_CLEAN_TMP_FILE

    ###@停止服务 @结束进程 @移除es###
    	process=`ps -ef |grep elasticsearch|egrep -v server |awk '{print $2}'`
        for i in ${process}
        do
                kill -9 $i
        done

    	bash ${INSTALL_DIR}/${INSTALL_SCRIPT} uninstall
	rm -rf /home/v2.2.1.tar.gz
        rm -rf /home/git-2.2.1
        rm -rf /usr/local/python3
        rm -rf /home/Python-3.6.1.tgz
        rm -rf /home/Python-3.6.1
        rm -rf /usr/bin/python3
	rm -rf /usr/bin/pip3
	rm -rf ${path}/logs

}

###调用所有函数###
function main()
{
	###@调用所有的函数###
	check_release
	init_env 
    	basic_function
	
	###@检查结果文件###
    	check_resultes ${RESULT_FILE}
	
	###@结果文件转为json文件，方便入库###
    	cd ${path}
    	python ${PY_JSON_TRANSFOR} ${RESULT_FILE} ${test_name}
	
	###@调用入库函数###
	
	###@清理环境###
    	clean_env 
	
	echo "case test Complete"
}

main 

