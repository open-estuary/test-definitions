#!/bin/bash
############################################################################
#
#       创建用户，创建普通用户testdb,并赋予本地和远程控制权限
#       创建/销毁testdb
#       压力测试：使用sysbench v0.5对mariadb进行压力测试
#作者：mwx547872
#完成时间：2019/5/13
#版本号：v0.1
##############################################################################

set -x
######初始化变量，新建一些文件######
path=`pwd`
INSTALL_DIR=${path}/../../../../../estuary-app/app_install_scripts # 指定安装脚本所在目录
INSTALL_SCRIPT=mariadb.sh # 指定安装脚本

PY_JSON_TRANSFOR=../../../../utils/result_transfor_json.py
######导入公共函数######
PUBLIC_UTILS_DIR=../../../../utils
. ${PUBLIC_UTILS_DIR}/sh-test-lib
. ${PUBLIC_UTILS_DIR}/sys_info.sh
. ${PUBLIC_UTILS_DIR}/test_case_common.inc
. ${PUBLIC_UTILS_DIR}/test_case_public.sh
######获取脚本名称作为测试用例名称######
test_name=$(basename $0 | sed -e 's/\.sh//')

######@创建log目录######

TMPDIR=${path}/logs
mkdir -p ${TMPDIR}

######存放每个测试步骤的执行结果#####
RESULT_FILE=${TMPDIR}/${test_name}.rst.log
function check_release()
{
	###@检测发行版###
	cat /etc/os-release
	uname -a
	dmidecode --type processor |grep Version
}

####初始化环境包含（日志开启入库，判断当前是否为root用户，安装所需要的包）#######
function init_env()
{
	###@开启日志入库导入
	#get_starttime

	###@安装mariadb
	bash ${INSTALL_DIR}/${INSTALL_SCRIPT}
	
	###@关闭防火墙 @安装需要使用的安装包，以及依赖包
	case $distro in
	centos)
	systemctl stop firewalld.service
        pkgs="expect git unzip gcc gcc-c++ automake autoconf make libtool mariadb-devel"
        install_deps --setopt=skip_missing_names_on_install=False "${pkgs}"
        ;;
        debian)
        pkgs="expect git unzip gcc g++ automake autoconf make libtool default-libmysqlclient-dev ufw"
        install_deps --setopt=skip_missing_names_on_install=False "${pkgs}"
        expect << EOF
	set timeout 100
	spawn ufw enable
	expect "Command may"
	send "y\r"
	expect eof
EOF
	;;
	esac

}

####mariadb的基本功能实现（版本检查，数据库初始化，创建用户，基本查询功能）#####

function basic_function()
{
         
	cd /usr/local/mariadb-10.3.7
	####@准备配置文件my.cnf
	touch ./etc/my.cnf
	echo "[mysqld]" >> ./etc/my.cnf
	echo "basedir=/usr/local/mariadb-10.3.7" >> ./etc/my.cnf
	echo "datadir=/ssd/data" >> ./etc/my.cnf
	echo "socket=/usr/local/mariadb-10.3.7/mysql.sock" >> ./etc/my.cnf
	echo "pid_file=/usr/local/mariadb-10.3.7/var/run/mysqld/mysqld.pid" >> ./etc/my.cnf
	echo "log_error=/usr/local/mariadb-10.3.7/var/log/mysqld.log" >> ./etc/my.cnf
	echo "port=2000" >> ./etc/my.cnf
	echo "user=root" >> ./etc/my.cnf
	echo "server_id=1" >> ./etc/my.cnf
	###@初始化mariadb
	./scripts/mysql_install_db --defaults-file=/usr/local/mariadb-10.3.7/etc/my.cnf
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "init_mariadb" "pass"
	else
		write_result "${RESULT_FILE}" "init_mariadb" "fail"
	fi

	###@启动mysqld进程
	nohup ./bin/mysqld_safe --defaults-file=/usr/local/mariadb-10.3.7/etc/my.cnf --ledir=/usr/local/mariadb-10.3.7/bin &
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "start_mariadb" "pass"
	else
		write_result "${RESULT_FILE}" "start_mariadb" "fail"
	fi
	sleep 5
	
	###@为root用户设置密码
	./bin/mysqladmin -S /usr/local/mariadb-10.3.7/mysql.sock -u root password 'root'
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "set-root-password" "pass"
	else
		write_result "${RESULT_FILE}" "set-root-password" "fail"
		exit 1
	fi
	#./bin/mysqladmin -S /usr/local/mariadb-10.3.7/mysql.sock -u root password ''
    
	###@创建新用户admin
	./bin/mysql --socket=/usr/local/mariadb-10.3.7/mysql.sock -u root -proot -e "insert into mysql.user(Host,User,Password) values("localhost","admin",password("admin"));"
	./bin/mysql --socket=/usr/local/mariadb-10.3.7/mysql.sock -u root -proot -e "flush privileges;"
	
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "create_user" "pass"
	else
		write_result "${RESULT_FILE}" "create_user" "fail"
	fi
	
	###@创建/销毁testdb
	./bin/mysql --socket=/usr/local/mariadb-10.3.7/mysql.sock -u root -proot -e "create database mydb;"
	./bin/mysql --socket=/usr/local/mariadb-10.3.7/mysql.sock -u root -proot -e "drop database mydb;"
	
	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "create_drop_db" "pass"
	else
		write_result "${RESULT_FILE}" "create_drop_db" "fail"
	fi
	
	
	cd -

}

####使用sysbench对mariadb进行压力测试######
function performance_test()
{
	####@压力测试

	ip_addr=`ip route | sed -r -n 's/.*dev (\w+).*src ([^ ]*) .*/\1 \2/p'|egrep -v "vir|br|vnet|lo|docker"|head -1|awk '{print $2}'`
	dmesg|grep D06
	if [ $? -eq 0 ];then
  	wget http://www.cpan.org/src/5.0/perl-5.16.1.tar.gz
	tar -xzf perl-5.16.1.tar.gz
	cd perl-5.16.1
	./Configure -des -Dprefix=/usr/local/perl -Dusethreads -Uinstalluserbinperl
	make
	make test
	make install
	mv /usr/bin/perl /usr/bin/perl.bak
	ln -s /usr/local/perl/bin/perl /usr/bin/perl
	cd ../
	fi
        #wget -O sysbench-0.5.zip http://192.168.1.107/sysbench-0.5.zip
	
	cd ${path}
	unzip sysbench-0.5.zip -d /usr/local/
	cd /usr/local/sysbench-0.5
	./autogen.sh
	./configure --prefix=/usr/local/sysbench-0.5 --with-mysql
	make
	make install

	./sysbench/sysbench --test=/usr/local/sysbench-0.5/sysbench/tests/db/parallel_prepare.lua --oltp-tables-count=250 --oltp-table-size=25000 --mysql-host=$ip_addr --mysql-port=2000 --mysql-db=testdb --mysql-user=test --mysql-password=test --num-threads=50 --max-requests=50 run


	./sysbench/sysbench --test=/usr/local/sysbench-0.5/sysbench/tests/db/oltp.lua --oltp-tables-count=250 --oltp-table-size=25000 --mysql-host=$ip_addr --mysql-port=2000 --mysql-db=testdb --mysql-user=test --mysql-password=test --oltp-read-only=on --oltp-point-selects=10 --oltp-simple-ranges=1 --oltp-sum-ranges=1 --oltp-order-ranges=1 --oltp-distinct-ranges=1 --oltp-range-size=10 --max-requests=0 --max-time=60 --report-interval=2 --forced-shutdown=1 --num-threads=100 run|grep "transactions"

	if [ $? -eq 0 ];then
		write_result "${RESULT_FILE}" "sysbench-mariadb-run" "pass"
	else
		write_result "${RESULT_FILE}" "sysbench-mariadb-run" "fail"
	fi
	cd - 
}

#####清理环境############
function clean_env()
{

	###@卸载安装包 @结束进程，清理临时文件 @导入测试结果入库结束
	cd /usr/local/mariadb-10.3.7
	./bin/mysqladmin -S /usr/local/mariadb-10.3.7/mysql.sock -u root -proot password ''
	if [ $? -eq 0 ];then
                echo "set-root-password is ok"
        else
                echo "set-root-password is not ok"
                exit 1
        fi
        ./bin/mysqladmin --socket=/usr/local/mariadb-10.3.7/mysql.sock -u root shutdown
    
	cd -
	#case $distro in
	#centos)
	#pkgs="expect automake libtool mariadb-devel"
	#remove_deps "${pkgs}"
	#;;
	#debian)
	#pkgs="expect automake libtool defaults-libmysqlclient-dev"
	#remove_deps "${pkgs}"
	#;;
	#esac

	bash ${INSTALL_DIR}/${INSTALL_SCRIPT} uninstall 
	rm -rf /usr/local/sysbench-0.5
	#rm -rf /usr/local/mariadb-10.3.7

}

#####调用所有函数############
function main()
{
	######调用所有的函数
	check_release
	init_env
	basic_function
	performance_test
	
	###@清理环境
	clean_env
	
	###@检查结果文件
	check_resultes ${RESULT_FILE}
      
	###@调用入库函数
	#avg_date $path0/${test_name}.json
	
	cd ${path}
	###@结果文件转换为json###
	python ../../../../utils/result_transfor_json.py ${RESULT_FILE} ${test_name}
	add_json ${test_name}.json
	rm -rf ${RESULT_FILE}
	echo "case test complete"

}

main

