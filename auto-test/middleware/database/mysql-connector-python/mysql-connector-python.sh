#!/bin/bash

#=================================================================
#   文件名称：mysql-connector-python.sh
#   创 建 者：dingyu ding_yu@hoperun.com
#   描    述：mysql-connector-python是MySQL官方的纯Python驱动,使用这个驱动让Python连接MySQL,测试创建数据库，创建表格,插入,删除,修改,查询数据等基本功能.
#
#================================================================*/
set -x

cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib
cd -

! check_root && error_msg "Please run this script as root."

##################### Environmental preparation ###################

pkg="expect python"
install_deps "${pkg}"

case "${distro}" in
    centos)
	source ./mysql.sh
	outDebugInfo
        yum erase -y mariadb-libs
        yum remove -y mariadb-libs
        cleanup_all_database
        pkgs1="mysql-community-server mysql-community-devel"
	install_deps "${pkgs1}"
	pkgs2="mysql-connector-python mysql-connector-python-cext"
	install_deps "${pkgs2}"
	print_info $? install_mysql_python

        ;;
    debian)
	./test.sh
	print_info $? delete_package
	apt-get remove --purge mysql-server
        pkgs="mysql-server mysql-client python-pip"
        install_deps "${pkgs}"
	print_info $? install-mysql-community
	pip install mysql-connector-python
	;;
esac

##################### the testing step ###########################
#启动mysql服务
systemctl start mysql
print_info $? start-mysqld

#给root用户添加密码
case "${distro}" in
    centos)
	mysqladmin -u root password "root"
	print_info $? set-root-pwd
	;;
    debian)
	EXPECT=$(which expect)
	$EXPECT << EOF
	set timeout 100
	spawn mysql -uroot -p
	expect "password:"
	send "root\r"
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
	systemctl restart mysql
	print_info $? set-root-pwd
	;;

esac




#Determine if the file exists
if !  test  -f "test.py" ;then
	echo "Error: Have not found test.py!!"
	exit 1
fi

python test.py | tee out.log
print_info $? build-mysql-python

cat out.log  | grep "success connect mysql"
print_info $? python-connect-db

cat out.log  | grep "success create test database"
print_info $? python-create-db

cat out.log  | grep "success choose database"
print_info $? python-choose-db

cat out.log  | grep "success create test table"
print_info $? python-create-table

cat out.log  | grep "success insert data"
print_info $? python-insert-data

cat out.log  | grep "success select data"
print_info $? python-select-data

cat out.log  | grep "success update data"
print_info $? python-update-data

cat out.log  | grep "success delete data"
print_info $? python-delete-data

cat out.log  | grep "success drop test table"
print_info $? python-drop-table

rm -f out.log

#删除数据库
EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn mysql -uroot -p
expect "password:"
send "root\r"
expect ">"
send "drop database test;\r"
expect "OK"
send "exit\r"
expect eof
EOF
print_info $? drop-database



####################  environment  restore ##############

systemctl stop mysql
print_info $? stop-mysqld

case "${distro}" in
    centos)
        remove_deps "${pkgs1}"
        print_info $? remove-mysql
        ;;
    debian)
	./test.sh
	apt-get remove --purge mysql-server
        print_info $? remove-mysql
	;;
esac

