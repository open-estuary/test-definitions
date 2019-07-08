#! /bin/bash

############################################################################
#用例名称：ycsb
#用例功能：
#	压力测试：使用ycsb全部自带负载完成elasticsearch压测
#			  使用ycsb全部自带负载完成mariadb压测
#			  使用ycsb全部自带负载完成mongodb压测
#			  使用ycsb全部自带负载完成redis压测
#	         
#作者     ：梅张 mwx694881
#完成时间 ：2019/5/31
#版本号   ： V0.1
##############################################################################

set -x

################################初始化变量################################
path=`pwd`
INSTALL_DIR=../../../../../estuary-app/app_install_scripts # 指定安装脚本所在目录
INSTALL_SCRIPT=${INSTALL_DIR}/ycsb.sh # 指定安装脚本
ELASTICSEARCH_SCRIPT=ycsb-elasticsearch.sh
REDIS_SCRIPT=ycsb-redis.sh
MONGODB_SCRIPT=ycsb-mongodb.sh
MARIADB_SCRIPT=ycsb-mariadb.sh
LOCAL_SRC_DIR="192.168.1.107/estuary"
PY_JSON_TRANSFOR=../../../../utils/result_transfor_json.py # 将测试结果转为json的python脚本
################################导入公共函数################################
PUBLIC_UTILS_DIR=${path}/../../../../utils/
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
RESULT_FILE=${TMPDIR}/ycsb_rst.log

#自定义函数区域（可选）
#function xxx()
#	{}

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

	###@判断是否为root用户	
	! check_root && error_msg "Please run this script as root."   
	
	###@检查结果文件是否存在，创建结果文件###
	check_resultfile ${RESULT_FILE}
	
	###@配置ycsb环境###
	case $distro in
	centos)
		yum install -y rpm
		;;
	debian)
		apt install -y rpm
		;;
	esac
	rpm -qa | grep java
	if [ $? -eq 0 ];then
		rpm -e --nodeps `rpm -qa | grep java`
	fi	
	###@安装JAVA###
	wget -O jdk-8u211-linux-arm64-vfp-hflt.tar.gz ${LOCAL_SRC_DIR}/jdk-8u211-linux-arm64-vfp-hflt.tar.gz
	tar -zxf jdk-8u211-linux-arm64-vfp-hflt.tar.gz -C /usr/local/
	echo 'export JAVA_HOME=/usr/local/jdk1.8.0_211' >> ~/.bashrc
	echo 'export JRE_HOME=${JAVA_HOME}/jre' >> ~/.bashrc
	echo 'export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib' >> ~/.bashrc
	echo 'export PATH=${JAVA_HOME}/bin:$PATH' >> ~/.bashrc
	source ~/.bashrc
	echo ${PATH}
	###@安装Maven###
	wget -O apache-maven-3.6.1-bin.tar.gz ${LOCAL_SRC_DIR}/apache-maven-3.6.1-bin.tar.gz
	tar -zxf apache-maven-3.6.1-bin.tar.gz -C /usr/local/	 
	echo 'export M2_HOME=/usr/local/apache-maven-3.6.1' >> /etc/profile.d/maven.sh
	echo 'export PATH=${M2_HOME}/bin:${PATH}' >> /etc/profile.d/maven.sh
	bash /etc/profile.d/maven.sh
	wget -O mariadb-java-client-2.4.0.jar ${LOCAL_SRC_DIR}/mariadb-java-client-2.4.0.jar
	###@调用安装脚本###
	chmod +x ${INSTALL_SCRIPT}
	${INSTALL_SCRIPT}
}

################################测试函数实现区域################################
###@test_mongodb###
function test_mongodb()
{
	###使用ycsb全部自带负载完成mongodb压测###
	chmod +x ${MONGODB_SCRIPT}
	./${MONGODB_SCRIPT}
}

###@test_mariadb###
function test_mariadb()
{
	###使用ycsb全部自带负载完成mariadb压测###
	chmod +x ${MARIADB_SCRIPT}
	./${MARIADB_SCRIPT}
}

###@test_redis###
function test_redis()
{
	###使用ycsb全部自带负载完成redis压测###
	chmod +x ${REDIS_SCRIPT}
	./${REDIS_SCRIPT}
}

###@test_elasticsearch###
function test_elasticsearch()
{
	###使用ycsb全部自带负载完成elasticsearch压测###
	chmod +x ${ELASTICSEARCH_SCRIPT}
	./${ELASTICSEARCH_SCRIPT}
}

################################基本功能测试################################
###基本功能测试###
function basic_function()
{  
	###@test###
	test_mongodb
	test_mariadb
	test_redis
	test_elasticsearch
}

################################清理环境################################
function clean_env()
{
	###@清除临时文件###
	#FUNC_CLEAN_TMP_FILE
	###@停止服务 @结束进程 @移除elasticsearch###
	${INSTALL_SCRIPT} uninstall	
	rpm -qa | grep java
	if [ $? -eq 0 ];then
		rpm -e --nodeps `rpm -qa | grep java`
	fi
	sed -i 's/export JAVA_HOME=\/usr\/local\/jdk1.8.0_211//g' /etc/bashrc
	sed -i 's/export JRE_HOME=\${JAVA_HOME}\/jre//g' /etc/bashrc
	sed -i 's/export CLASSPATH=.:\${JAVA_HOME}\/lib:\${JRE_HOME}\/lib//g' /etc/bashrc
	sed -i 's/export PATH=\${JAVA_HOME}\/bin:\$PATH//g' /etc/bashrc	
	source /etc/bashrc
	rm -rf /usr/local/jdk1.8.0_211
	rm -rf $path/apache-maven-3.6.1-bin.tar.gz $path/jdk-8u211-linux-arm64-vfp-hflt.tar.gz $path/mariadb-java-client-2.4.0.jar 
	case $distro in
	centos)
		yum install -y java
		;;
	debian)
		apt install  openjdk-8-jdk -y
		;;
esac
}

#####调用所有函数############
function main()
{
	###调用所有的函数###
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
	
	###@调用入库函数###
	#data_to_db ${path}/${test_name}.json 
	rm -rf ${RESULT_FILE}
	echo "case test Complete"
}

main 
