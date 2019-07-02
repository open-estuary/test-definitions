#!/bin/bash

############################################################################
#用例名称：pipework
#用例功能：
#    1. 提供用例编写规范
#    2. 其它
#作者    ：刘北洁 lwx588815
#完成时间：2019/05/29
#版本号  ： V0.1
##############################################################################
set -x
################################初始化变量################################
path=`pwd`
INSTALL_DIR=../../../../../estuary-app/app_install_scripts
INSTALL_SCRIPT=pipework.sh # 指定安装脚本
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
	dmidecode --type processor | grep Version
}


################################初始化环境包含（安装所需要的包）################################
function init_env()
{ 
	###@开启日志入库时间### 
	#get_starttime
	
	###@调用安装脚本###
	${INSTALL_DIR}/${INSTALL_SCRIPT}
	
	###@检查结果文件是否存在，创建结果文件###
	check_resultfile ${RESULT_FILE}

	ip route | sed -r -n 's/.*dev (\w+).*src ([^ ]*) .*/\1 \2/p'|egrep -v "vir|br|vnet|lo|docker"|tee ip_net.txt
	ip_board=`cat ip_net.txt|head -1|awk '{print $2}'`     ###本机IP
	network=`cat ip_net.txt|head -1|awk '{print $1}'`      ###本机网卡
	ip_3=`cat ip_net.txt|head -1|awk '{print $2}'|awk -F"." '{print $1 "." $2 "." $3}'|head -1`    ###本机ip的前三位
	ip_4=`cat ip_net.txt|head -1|awk '{print $2}'|awk -F"." '{print $4}'|head -1`       ###本机ip的最后一位
	gatway_ip=${ip_3}.1       ###网关IP
	max=$[255-$ip_4]
	for((i=2;i<$max;i++))
	do
		ip=$[$ip_4+$i] 
		docker_ip=$ip_3.$ip 
		ping ${docker_ip} -c 1 2>&1 |tee a.txt|grep Unreachable 
		if [ $? -eq 0 ];then
			break
		fi
	done
}


################################测试函数实现区域################################
###@test1###
function test1()
{
	cd /home/pipework
	systemctl start docker
	systemctl status docker|grep -i "running"
	if [ $? -eq 0 ];then
		echo "docker_runing"
	else
		echo "docker_fail"
	fi

	case "${distro}" in
		centos)
			docker run --privileged=true -idt -v /home/pipetest:/home/ --name pipe22tt centos /bin/bash
			if [ $? -eq 0 ];then
				echo "centos_pass"
			else
				echo "centos_fail"
			fi
			;;
		debian)
			docker run --privileged=true -idt -v /home/pipetest:/home/ --name pipe22tt debian /bin/bash
			if [ $? -eq 0 ];then
				echo "debian_pass"
			else
				echo "debian_fail"
			fi
			;;
	esac
	pipework br0 pipe22tt ${docker_ip}/24@${gatway_ip}
	if [ $? -eq 0 ];then
		echo "docker_ip_pass"
	else
		echo "docker_ip_fail"
	fi


	ip addr add ${ip_board}/24 dev br0; \
	ip addr del ${ip_board}/24 dev ${network}; \
	brctl addif br0 ${network}; \
	ip route del default; \
	ip route add default via ${gatway_ip} dev br0
	ip addr show br0|grep "$gatway_ip"

	ping ${docker_ip} -c 2 2>&1|tee -a ee.txt| grep "Unreachable"
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "docker_ping" "fail"
	else
		write_result "${RESULT_FILE}" "docker_ping" "pass"
	fi
}


################################基本功能测试################################
###基本功能测试###
function basic_function()
{
	###@test1###
	test1
	
}


################################清理环境################################
function clean_env()
{
	###@清除临时文件###
	rm -rf ip_net.txt a.txt
	docker stop pipe22tt
	docker rm pipe22tt
	systemctl stop docker
	###结束进程###
	process=`ps -ef |grep docker|grep server |awk '{print $2}'`
	for i in ${process}
	do
		kill -9 $i
	done
	###卸载###
	bash ${INSTALL_DIR}/${INSTALL_SCRIPT} uninstall
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


