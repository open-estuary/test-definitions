#!/bin/bash

############################################################################
#用例名称：$lamp_function.sh
#用例功能：
#验证lamp可否实现正常安装使用
#作者：swx703520
#完成时间：2019/5/22
#版本号  ： V0.1
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
INSTALL_SCRIPT=${INSTALL_DIR}/lamp.sh # 指定安装脚本
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

################################初始化环境包含（安装所需要的包）################################
function init_env()
{
    ###@开启日志入库时间###
    #get_starttime
    chmod +x ${INSTALL_SCRIPT}
    ###@调用安装脚本###
    ${INSTALL_SCRIPT}
    ###@检查结果文件是否存在，创建结果文件###
    check_resultfile ${RESULT_FILE}
}

function test1()
{
###Debian###
case "${distro}" in
    debian)
	case "${distro}" in
		debian)
			cp /etc/php/7.0/apache2/php.ini /etc/php/7.0/apache2/php.ini.bak
			echo "extension=mysqli.so">> /etc/php/7.0/apache2/php.ini
			systemctl stop php7.0-fpm
			systemctl start php7.0-fpm
			pro=`systemctl status php7.0-fpm`
			echo $pro
		
			systemctl stop apache2
			systemctl start apache2
			STATUS=`systemctl status apache2`
			echo $STATUS
			
			systemctl start php-fpm
			systemctl start httpd.service
			systemctl start mysql
			cat /var/log/mysqld.log
			STATUS=`systemctl status mysql`
			echo $STATUS
			if [ $? -eq 0 ];then
            ###@把测试的结果写入到结果文件中###
				write_result "${RESULT_FILE}" "service_command" "pass"
			else
				write_result "${RESULT_FILE}" "service_command" "fail"
			fi
			;;
			*)
			error_msg "Unsupported distribution!"
	esac
			sed -i "s/Nginx/Apache/g" ./html/index.html
			cp ./html/* /var/www/html/

			#Test Apache.
			curl -o "output" "http://localhost/index.html"
             		#print_info $? apache2-test-page
			if [ $? -eq 0 ];then
            		###@把测试的结果写入到结果文件中###
				write_result "${RESULT_FILE}" "apachphp_command" "pass"
			else
				write_result "${RESULT_FILE}" "apachphp_command" "fail"
			fi           
			#cat output
            		#grep "Test Page for the Apache HTTP Server" ./output
            		#print_info $? apache2-test-page
            #Test MySQL.
    	case "${distro}" in
        	debian)
           		EXPECT=$(which expect)
            		$EXPECT << EOF
            		set timeout 100
            		spawn mysql -u root -p
            		expect "password:"
            		send "root\r"
            		expect ">"
            		send "use mysql;\r"
            		expect ">"
            		send "UPDATE mysql.user SET authentication_string=PASSWORD('Avalon'), plugin='mysql_native_password' WHERE user='root';\r"
            		expect "OK"
            		send "UPDATE user SET authentication_string=PASSWORD('lxmptest') where USER='root';\r"
            		expect "OK"
            		send "FLUSH PRIVILEGES;\r"
            		expect "OK"
            		send "exit\r"
            		expect eof
EOF
            		print_info $? set-root-pwd
            		;;
    	esac

    	case "${distro}" in
        	ubuntu|debian)
            		$EXPECT << EOF
            		set timeout 100
            		spawn mysql -uroot -p
            		expect "password:"
            		send "lxmptest\r"
            		expect ">"
            		send "use mysql;\r"
            		expect ">"
            		send "UPDATE mysql.user SET authentication_string=PASSWORD('Avalon'), plugin='mysql_native_password' WHERE user='root';\r"
            		expect "OK"
            		send "UPDATE user SET authentication_string=PASSWORD('root') where USER='root';\r"
            		expect "OK"
            		send "FLUSH PRIVILEGES;\r"
            		expect "OK"
            		send "exit\r"
			expect eof
EOF
            		;;
    	esac

			#mysqladmin -u root password root  > /dev/null 2>&1 || true
			mysql --user="root" --password="root" -e "show databases"
            		if [ $? -eq 0 ];then
                	###@把测试的结果写入到结果文件中###
                		write_result "${RESULT_FILE}" "showdb_command" "pass"
            		else
                		write_result "${RESULT_FILE}" "showdb_command" "fail"
            		fi
			#查看mysql的端口号
			netstat -tnl|grep 3306
            		if [ $? -eq 0 ];then
                		###@把测试的结果写入到结果文件中###
                		write_result "${RESULT_FILE}" "mysqlport_command" "pass"
            		else
                		write_result "${RESULT_FILE}" "mysqlport_command" "fail"
            		fi
			# 检测正常访问apache结合php解析页面
			curl -o "output" "http://localhost/info.php"
			cat output
			grep "PHP Version" ./output
			curl -o "output" "http://localhost/connect-db.php"
			cat output
			grep "Connected successfully" ./output
			#exit_on_fail "php-connect-db"
            		if [ $? -eq 0 ];then
                		###@把测试的结果写入到结果文件中###
                		write_result "${RESULT_FILE}" "cntdb_command" "pass"
            		else
                		write_result "${RESULT_FILE}" "cntdb_command" "fail"
            		fi

			# php是否可以正常创建一个新mysql的库
			curl -o "output" "http://localhost/create-db.php"
			#cat output
			#grep "Database created successfully" ./output
            		#if [ $? -eq 0 ];then
                		###@把测试的结果写入到结果文件中###
                		#write_result "${RESULT_FILE}" "mqlport5_command" "pass"
            		#else
                		#write_result "${RESULT_FILE}" "mqlport5_command" "fail"
            		#fi

			#php是否可以正常创建一个mysql表
			curl -o "output" "http://localhost/create-table.php"
			cat output
			grep "Table MyGuests created successfully" ./output
			mysql --user='root' --password='root' -e 'DROP DATABASE myDB'
	case "$distro" in
        	debian)
           		i=0
            		systemctl stop apache2
            		if [ $? -eq 0 ];then
                		let i=$i+1
            		fi
            		systemctl stop mysql
            		if [ $? -eq 0 ];then
                		let i=$i+1
            		fi
            		systemctl stop php7.0-fpm
            		if [ $? -eq 0 ];then
                		let i=$i+1
            		fi
            		if [ $i -eq 3 ];then
                		write_result "${RESULT_FILE}" "systemctl_stop" "pass"
            		else
                		write_result "${RESULT_FILE}" "systemctl_stop" "fail"
            		fi
            		;;
    	esac
    	;;
esac

#######Centos#######
case "${distro}" in
	centos)
    	case "${distro}" in
        	centos)
            		a=0
            		systemctl start php-fpm
            		if [ $? -eq 0 ];then
                		let a=$a+1
            		fi
            		systemctl start httpd.service
            		if [ $? -eq 0 ];then
                		let a=$a+1
            		fi
            		service httpd status
            		if [ $? -eq 0 ];then
                		let a=$a+1
            		fi
            		systemctl start mysql
            		if [ $? -eq 0 ];then
                		let a=$a+1
            		fi
            		if [ $a -eq 4 ];then
            		###@把测试的结果写入到结果文件中###
                		write_result "${RESULT_FILE}" "mysql_command" "pass"
            		else
                		write_result "${RESULT_FILE}" "mysql_command" "fail"
            		fi
            		cat /var/log/mysqld.log
			STATUS=`systemctl status mysql`
            		echo $STATUS
        		;;
        	*)
            		error_msg "Unsupported distribution!"
	esac
			#######修改index.html并复制到/var/www/html/
			sed -i "s/Nginx/Apache/g" ./html/index.html
			cp ./html/* /var/www/html/

			##### Test Apache.
			curl -o "output" "http://localhost/index.html"
			cat output
			grep "Test Page for the Apache HTTP Server" ./output
			if [ $? -eq 0 ];then
				###@把测试的结果写入到结果文件中###
				write_result "${RESULT_FILE}" "apachphp_command" "pass"
			else
				write_result "${RESULT_FILE}" "apachphp_command" "fail"
			fi


#####Test MySQL.
	case "${distro}" in
        	centos)
			EXPECT=$(which expect)
                	$EXPECT << EOF
                	set timeout 100
                	spawn mysql -u root -p
                	expect "password:"
                	send "root\r"
                	expect ">"
                	send "exit\r"
                	expect eof
EOF
			if [ $? -eq 1 ];then
				mysqladmin -u root password root
			fi
			#if [ $? -eq 0 ];then
				###@把测试的结果写入到结果文件中###
                		#write_result "${RESULT_FILE}" "setrot_command" "pass"
			#else
                		#write_result "${RESULT_FILE}" "setrot_command" "fail"
			#fi
            		systemctl restart mysql
            		;;
    	esac
			#查看mysql的端口号
            		netstat -tnl|grep 3306
            		if [ $? -eq 0 ];then
            		###@把测试的结果写入到结果文件中###
                		write_result "${RESULT_FILE}" "mysqlport_command" "pass"
			else
                		write_result "${RESULT_FILE}" "mysqlport_command" "fail"
			fi

			#mysqladmin -u root password root  > /dev/null 2>&1 || true
            		mysql --user="root" --password="root" -e "show databases"
            		if [ $? -eq 0 ];then
            		###@把测试的结果写入到结果文件中###
                		write_result "${RESULT_FILE}" "showdb_command" "pass"
			else
                		write_result "${RESULT_FILE}" "showdb_command" "fail"
			fi

			# Test PHP.
			curl -o "output" "http://localhost/info.php"
			cat output
			grep "PHP Version" ./output
			#if [ $? -eq 0 ];then
            		###@把测试的结果写入到结果文件中###
				#write_result "${RESULT_FILE}" "phpinfo_command" "pass"
			#else
				#write_result "${RESULT_FILE}" "phpinfo_command" "fail"
			#fi

			# PHP Connect to MySQL.
			curl -o "output" "http://localhost/connect-db.php"
			cat output
			grep "Connected successfully" ./output
			#exit_on_fail "php-connect-myDB"
			if [ $? -eq 0 ];then
            		###@把测试的结果写入到结果文件中###
				write_result "${RESULT_FILE}" "cntdb_command" "pass"
			else
				write_result "${RESULT_FILE}" "cntdb_command" "fail"
			fi
			#case "$distro" in
			#centos)
                	i=0
                	systemctl stop httpd
                	if [ $? -eq 0 ];then
                    	let i=$i+1
                	fi
                	systemctl stop mysql
                	if [ $? -eq 0 ];then
                    		let i=$i+1
                	fi
                	systemctl stop php-fpm
                	if [ $? -eq 0 ];then
                    		let i=$i+1
                	fi
                	if [ $i -eq 3 ];then
                    		write_result  "${RESULT_FILE}" "systemctl_stop" "pass"
                	else
                    		write_result  "${RESULT_FILE}" "systemctl_stop" "fail"
                	fi
			#;;
			#esac
			#####删除80端口占用进程
			lsof -i :80|grep -v "PID"|awk '{print "kill -9",$2}'|sh
			if [ $? -eq 0 ];then
                		echo kill_80_pass
			else
                		echo kill_80_fail
			fi
			;;
esac

}
####################注释：如环境未清理干净不能正常安装，可添加test2到function basic_function()函数中执行，清理环境###############
function test2()
{
case "$distro" in
	debian)
            	rm -rf /etc/php/7.0/apache2/php.ini
            	cp /etc/php/7.0/apache2/php.ini.bak /etc/php/7.0/apache2/php.ini
            	apt-get remove apache2 --purge -y
            	apt-get remove php-fpm --purge -y
            	apt-get remove mysql-serser --purge -y
            	;;
        centos)
            	yum remove -y `rpm -qa | grep -i mysql`
            	remove_deps "${pkgs}"
		print_info $? remove-package
        	;;
esac
}

################################基本功能测试################################
###基本功能测试###
function basic_function()
{
		test1
}

#####清理环境############
#停止服务
function clean_env()
{
        rm -rf output
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
	check_resultes ${RESULT_FILE}
        ###@结果文件转为json文件，方便入库###
	python ${PY_JSON_TRANSFOR} ${RESULT_FILE} ${test_name}
        add_json ${test_name}.json
        ###@调用入库函数###
        #data_to_db ${PWD}/${test_name}.json

        echo -e "\033[32m case test Complete \033[0m"
}

main
                         
