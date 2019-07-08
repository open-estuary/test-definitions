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
set -x

######初始化变量，新建一些文件######
INSTALL_DIR=../../../../../estuary-app/app_install_scripts
INSTALL_SCRIPT=nginx_install.sh # 指定安装脚本
PY_JSON_TRANSFOR=../../../../utils/result_transfor_json.py # 将测试结果转为json的python脚本
################################导入公共函数################################
PUBLIC_UTILS_DIR=../../../../utils
. ${PUBLIC_UTILS_DIR}/sys_info.sh
. ${PUBLIC_UTILS_DIR}/sh-test-lib
. ${PUBLIC_UTILS_DIR}/test_case_common.inc
. ${PUBLIC_UTILS_DIR}/test_case_public.sh
################################获取脚本名称作为测试用例名称################################
test_name=$(basename $0 | sed -e 's/\.sh//')
echo $test_name
################################@创建log目录################################
TMPDIR=./logs
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
	# get_starttime
	 ###@调用安装脚本###
	bash ${INSTALL_DIR}/${INSTALL_SCRIPT}

	###@关闭防火墙
	case $distro in
	centos)
	systemctl stop firewalld.service
	pkgs="curl" 
	install_deps "${pkgs}"
	;;
	debian)
	pkgs="curl"
	install_deps "${pkgs}"
	apt-get install ufw -y
	EXPECT << EOF
	set timeout 100
	spawn ufw enable
	expect "Command may"
	send "y\r"
	expect eof
EOF

	;;
	esac
  
	###@检查结果文件是否存在，创建结果文件###
	check_resultfile ${RESULT_FILE}

}

####nginx的http功能（版本检查，验证配置文件，启动nginx,解析HTTP请求）#####
function nginx-http()
{

	###@准备html文件
	cp /usr/local/nginx/html/index.html /usr/local/nginx/html/hello.html
	sed -i 's/Welcome to nginx/hello http/g' /usr/local/nginx/html/hello.html
	###@修改配置
	mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf_bak1
	touch /usr/local/nginx/conf/nginx.conf
	cat >/usr/local/nginx/conf/nginx.conf<<EOF
	worker_processes  1;
	events {
	worker_connections  1024;
	}
	http {
	include       mime.types;
	default_type  application/octet-stream;
	sendfile        on;
	keepalive_timeout  65;
	server {
	listen       80;
	server_name  localhost;

	location / {
	root   html;
	index  index.html index.htm hello.html;
	}

	}

	error_page   500 502 503 504  /50x.html;
	}

EOF
	###@验证配置文件
	/usr/local/nginx/sbin/nginx -t
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "check-http-configuration" "pass"

	else

		write_result "${RESULT_FILE}" "check-http-configuration" "fail"

	fi

	###@启动nginx
	/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf &
	if [ $? -eq 0 ];then

		write_result "${RESULT_FILE}" "star-http-nginx" "pass"

	else

		write_result "${RESULT_FILE}" "start-http-nginx" "fail"

	fi

	###@处理http请求
	curl http://127.0.0.1/hello.html|grep "hello http"
	if [ $? -eq 0 ];then

		write_result "${RESULT_FILE}" "check-http-request" "pass"

	else

		write_result "${RESULT_FILE}" "check-http-request" "fail"

	fi         
	####@清理环境####
	/usr/local/nginx/sbin/nginx -s stop

}
function nginx-https()
{
	cd nginx-1.14.0
	cp objs/nginx /usr/local/nginx/sbin/nginx
	cd ../
	###@解压CA证书
	tar -xvf CA.tar.gz -C /usr/local/nginx/conf
	###@准备html文件
	cp /usr/local/nginx/html/index.html /usr/local/nginx/html/hello1.html
	sed -i 's/Welcome to nginx/hello https/g' /usr/local/nginx/html/hello1.html
	###@修改配置
	mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf_bak2
	cp nginx-https.conf /usr/local/nginx/conf/nginx.conf
	# touch /usr/local/nginx/conf/nginx.conf
	###@验证配置文件
	/usr/local/nginx/sbin/nginx -t 
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "check-https-file" "pass"

	else

		write_result "${RESULT_FILE}" "check-https-file" "fail"

	fi

	###@启动nginx
	/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf &
	if [ $? -eq 0 ];then

		write_result "${RESULT_FILE}" "star-https-nginx" "pass"

	else

		write_result "${RESULT_FILE}" "start-https-nginx" "fail"

	fi

       
	###@处理https请求
	curl http://127.0.0.1/hello1.html -k|grep "hello https"
	if [ $? -eq 0 ];then

		write_result "${RESULT_FILE}" "check-https-request" "pass"

	else

		write_result "${RESULT_FILE}" "check-https-request" "fail"

	fi

 
	###@卸载安装包 @结束进程，
	/usr/local/nginx/sbin/nginx -s stop

}


function nginx-image()
{
	###@修改配置
	mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf_bak3
	touch /usr/local/nginx/conf/nginx.conf
	cat >/usr/local/nginx/conf/nginx.conf<<EOF
	worker_processes  1;
	events {
	worker_connections  1024;
	}
	http {
	include       mime.types;
	default_type  application/octet-stream;
	sendfile        on;
	keepalive_timeout  65;
	server {
	listen       80;
	server_name  localhost;

	location / {
	root   html;
	index  index.html index.htm hello.html;
	}
	location ~* /images {
	image_filter resize 100 50;
	}

	}

	error_page   500 502 503 504  /50x.html;
	}

EOF

	mkdir -p /usr/local/nginx/html/images
	cp 111.jpg /usr/local/nginx/html/images
	###@验证配置文件
	/usr/local/nginx/sbin/nginx -t 
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "check-images-configuration" "pass"

	else

		write_result "${RESULT_FILE}" "check-images-configuration" "fail"

	fi

	###@启动nginx
	/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf &
	if [ $? -eq 0 ];then

		write_result "${RESULT_FILE}" "images-star-nginx" "pass"

	else

		write_result "${RESULT_FILE}" "images-start-nginx" "fail"

	fi

       
	###@处理http请求
	curl http://127.0.0.1/images/111.jpg
	if [ $? -eq 0 ];then

		write_result "${RESULT_FILE}" "check-images-request" "pass"

	else

		write_result "${RESULT_FILE}" "check-images-request" "fail"

	fi


	###@卸载安装包 @结束进程，清理临时文件 @导入测试结果入库结束
	/usr/local/nginx/sbin/nginx -s stop

}
function nginx-js()
{

	mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf_bak4
	touch /usr/local/nginx/conf/nginx.conf
	cat >/usr/local/nginx/conf/nginx.conf<<EOF
	worker_processes  1;
	events {
	worker_connections  1024;
	}
	http {
	include       mime.types;
	js_include hello.js;
	default_type  application/octet-stream;
	sendfile        on;
	keepalive_timeout  65;
	server {
		listen       8012;

		location / {
		js_content   hello;
		}

	}


}			

EOF
	cp hello.js /usr/local/nginx/conf
	###@验证配置文件
	/usr/local/nginx/sbin/nginx -t 
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "check-js-configuration" "pass"

	else

		write_result "${RESULT_FILE}" "check-js-configuration" "fail"

	
	fi

	###@启动nginx
	/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf &
	if [ $? -eq 0 ];then

		write_result "${RESULT_FILE}" "js-star-nginx" "pass"

	else

		write_result "${RESULT_FILE}" "js-start-nginx" "fail"

          fi

       
	###@处理http请求
	curl 127.0.0.1:8012|grep "hello world"
	if [ $? -eq 0 ];then

		write_result "${RESULT_FILE}" "js-check-request" "pass"

	else

		write_result "${RESULT_FILE}" "js-check-request" "fail"

	fi



	###@卸载安装包 @结束进程，清理临时文件 @导入测试结果入库结束
	/usr/local/nginx/sbin/nginx -s stop

}

function basic_function()
{

	nginx-http
	nginx-https
	nginx-image
	nginx-js 
}



#####清理环境############
function clean_env()
{

	###@卸载安装包 @结束进程，清理临时文件 @导入测试结果入库结束
	case $distro in
	centos)
	pkgs="pcre2-static openssl-static"
	remove_deps "${pkgs}"
	;;
	debian)
	pkgs="pcre2-utils openssl"
	remove_deps "${pkgs}"
	;;
	esac
	bash ${INSTALL_DIR}/${INSTALL_SCRIPT} uninstall    

}

#####调用所有函数############
function main()
{
	####@调用所有的函数
	init_env
	basic_function
	###@检查结果文件###
	check_resultes ${RESULT_FILE}
	###@清理环境
	clean_env
	###@结果文件转为json文件，方便入库###
	cd $PWD
	python ${PY_JSON_TRANSFOR} ${RESULT_FILE} ${test_name}
        add_json ${test_name}.json
	###@清理环境###
	rm -rf ${RESULT_FILE}
	rm -rf logs/
	echo "case test Complete"
}
main

