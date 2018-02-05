#!/bin/bash

set -x

cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

yum erase -y mariadb-libs
yum remove -y mariadb-libs
yum update -y

pkgs="mysql-community-common mysql-community-server 
	mysql-community-client mysql-community-devel expect"
install_deps "${pkgs}"
print_info $? install-mysql-community

pkgs="python"
install_deps "${pkgs}"
print_info $? install-python

pkgs="mysql-connector-python mysql-connector-python-cext mysql-connector-python-debuginfo"
install_deps "${pkgs}"
print_info $? install-mysql-connector-python

systemctl start mysqld
print_info $? start-mysqld

mysqladmin -u root password "root"
print_info $? set-root-pwd

EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn mysqladmin -uroot -p create test
expect "password:"
send "root\r"
expect eof
EOF
print_info $? create-database

find . -name "test.py"
if [ $? ];then
	echo "Error: Have not found test.py!!"
	exit 0
fi

python test.py | tee out.log
print_info $? build-mysql-python

cat out.log  | grep "success connect mysql"
print_info $? python-connect-db

cat out.log  | grep "success use test database"
print_info $? python-use-db

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

EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn mysql -uroot -p
expect "password:"
send "root\r"
expect "mysql>"
send "drop database test;\r"
expect "OK"
send "exit\r"
expect eof
EOF
print_info $? drop-database

systemctl stop mysqld
print_info $? stop-mysqld

yum remove -y mysql-connector-python mysql-connector-python-cext mysql-connector-python-debuginfo
print_info $? remove-mysql-connector-python

yum remove -y python
print_info $? remove-python

yum remove -y mysql-community-server mysql-community-common mysql-community-client mysql-community-devel
print_info $? remove-mysql-community

